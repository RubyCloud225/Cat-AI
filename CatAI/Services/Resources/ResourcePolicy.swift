import Foundation

/// A platform-independent representation of thermal pressure.
enum ThermalLevel: Sendable, Equatable {
    case nominal
    case fair
    case serious
    case critical
    case unknown
}

/// One observation of the machine's resource condition.
/// GPU power is optional because a supported live wattage source
/// has not yet been integrated.
struct ResourceSample: Sendable {
    let thermal: ThermalLevel
    let gpuWatts: Double?
}

struct ResourceLimits: Sendable {
    let maxContinuousInference: Duration
    let cooldown: Duration
    let maxGPUWatts: Double?

    static let quick = ResourceLimits(
        maxContinuousInference: .seconds(20),
        cooldown: .seconds(30),
        maxGPUWatts: nil
    )

    static let balanced = ResourceLimits(
        maxContinuousInference: .seconds(40),
        cooldown: .seconds(30),
        maxGPUWatts: nil
    )

    static let extended = ResourceLimits(
        maxContinuousInference: .seconds(60),
        cooldown: .seconds(30),
        maxGPUWatts: nil
    )
}

enum AdmissionResult: Sendable, Equatable {
    case admitted
    case deferred(reason: String)
}

/// Serialises Cat AI request admission and cancellation decisions.
///
/// LIMITATION: Cancellation releases the logical slot immediately.
/// The Ollama integration must prove that a cancelled backend request
/// has actually stopped before allowing another GPU workload.
actor ResourceController {
    private struct ActiveRequest {
        let id: UUID
        let started: ContinuousClock.Instant
        let cancel: @Sendable () -> Void
    }

    private let limits: ResourceLimits
    private var sample = ResourceSample(
        thermal: .unknown,
        gpuWatts: nil
    )

    private var active: ActiveRequest?
    private var recoveryRequired = false
    private var recoveryStarted: ContinuousClock.Instant?

    init(limits: ResourceLimits) {
        self.limits = limits
    }

    /// Records telemetry and checks an active request against safeguards.
    func update(
        _ newSample: ResourceSample,
        at now: ContinuousClock.Instant = .now
    ) {
        sample = newSample

        if newSample.thermal == .serious ||
           newSample.thermal == .critical {
            recoveryRequired = true
            recoveryStarted = nil
        } else if newSample.thermal == .nominal {
            if recoveryRequired && recoveryStarted == nil {
                recoveryStarted = now
            }
        } else {
            // Nominal recovery must be continuous.
            recoveryStarted = nil
        }

        if recoveryRequired,
           newSample.thermal == .nominal,
           let started = recoveryStarted,
           started.duration(to: now) >= limits.cooldown,
           powerAllowed(newSample) {
            recoveryRequired = false
            recoveryStarted = nil
        }

        guard let request = active else { return }

        let unsafeThermal =
            newSample.thermal == .serious ||
            newSample.thermal == .critical ||
            newSample.thermal == .unknown

        let timedOut =
            request.started.duration(to: now) >=
            limits.maxContinuousInference

        if unsafeThermal ||
           !powerAllowed(newSample) ||
           timedOut {
            // Clear ownership before requesting cancellation to avoid
            // duplicate cancellation from successive telemetry samples.
            active = nil
            request.cancel()
        }
    }

    /// Reserves the sole Cat AI inference slot if policy permits it.
    func begin(
        id: UUID,
        cancel: @escaping @Sendable () -> Void,
        at now: ContinuousClock.Instant = .now
    ) -> AdmissionResult {
        guard active == nil else {
            return .deferred(reason: "Inference already running")
        }

        guard sample.thermal == .nominal else {
            return .deferred(reason: "Thermal state not nominal")
        }

        guard !recoveryRequired else {
            return .deferred(reason: "Cooling period in progress")
        }

        guard powerAllowed(sample) else {
            return .deferred(reason: "Power budget unavailable or exceeded")
        }

        active = ActiveRequest(
            id: id,
            started: now,
            cancel: cancel
        )
        return .admitted
    }

    /// An old request cannot release a newer request's slot.
    func finish(id: UUID) {
        guard active?.id == id else { return }
        active = nil
    }

    func stop(id: UUID) {
        guard let request = active,
              request.id == id else { return }

        active = nil
        request.cancel()
    }

    private func powerAllowed(_ sample: ResourceSample) -> Bool {
        guard let ceiling = limits.maxGPUWatts else {
            return true
        }

        // When a power limit is configured, missing/invalid telemetry
        // must not be interpreted as permission to run.
        guard ceiling.isFinite, ceiling > 0,
              let watts = sample.gpuWatts,
              watts.isFinite, watts >= 0 else {
            return false
        }

        return watts <= ceiling
    }
}

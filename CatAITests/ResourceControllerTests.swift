import Foundation
import Testing

/// A lock-protected counter, safe to call from Sendable closures.
private final class CancellationProbe: @unchecked Sendable {
    private let lock = NSLock()
    private var cancellations = 0

    func cancel() {
        lock.lock()
        defer { lock.unlock() }
        cancellations += 1
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return cancellations
    }
}

struct ResourceControllerTests {
    @Test
    func nominalStateAllowsInference() async {
        let controller = ResourceController(limits: .quick)
        await controller.update(
            ResourceSample(thermal: .nominal, gpuWatts: nil)
        )

        let result = await controller.begin(id: UUID(), cancel: {})
        #expect(result == .admitted)
    }

    @Test
    func fairStateDefersNewRequests() async {
        let controller = ResourceController(limits: .quick)
        await controller.update(
            ResourceSample(thermal: .fair, gpuWatts: nil)
        )

        let result = await controller.begin(id: UUID(), cancel: {})
        #expect(result != .admitted)
    }

    @Test
    func criticalStateCancelsExactlyOnce() async {
        let controller = ResourceController(limits: .quick)
        let probe = CancellationProbe()

        await controller.update(
            ResourceSample(thermal: .nominal, gpuWatts: nil)
        )
        let admission = await controller.begin(
            id: UUID(),
            cancel: { probe.cancel() }
        )
        #expect(admission == .admitted)

        let critical = ResourceSample(thermal: .critical, gpuWatts: nil)
        await controller.update(critical)
        await controller.update(critical)

        #expect(probe.count == 1)
    }

    @Test
    func simultaneousRequestsAreNotAdmitted() async {
        let controller = ResourceController(limits: .balanced)
        await controller.update(
            ResourceSample(thermal: .nominal, gpuWatts: nil)
        )

        let first = await controller.begin(id: UUID(), cancel: {})
        let second = await controller.begin(id: UUID(), cancel: {})

        #expect(first == .admitted)
        #expect(second != .admitted)
    }

    @Test
    func recoveryRequiresContinuousCooldown() async {
        let controller = ResourceController(limits: .quick)
        let start = ContinuousClock.now

        await controller.update(
            ResourceSample(thermal: .serious, gpuWatts: nil),
            at: start
        )
        await controller.update(
            ResourceSample(thermal: .nominal, gpuWatts: nil),
            at: start.advanced(by: .seconds(1))
        )

        let early = await controller.begin(
            id: UUID(),
            cancel: {},
            at: start.advanced(by: .seconds(20))
        )
        #expect(early != .admitted)

        await controller.update(
            ResourceSample(thermal: .nominal, gpuWatts: nil),
            at: start.advanced(by: .seconds(31))
        )

        let recovered = await controller.begin(
            id: UUID(),
            cancel: {},
            at: start.advanced(by: .seconds(31))
        )
        #expect(recovered == .admitted)
    }

    @Test
    func continuousTimeLimitCancelsInference() async {
        let controller = ResourceController(limits: .quick)
        let probe = CancellationProbe()
        let start = ContinuousClock.now
        let nominal = ResourceSample(
            thermal: .nominal,
            gpuWatts: nil
        )

        await controller.update(nominal, at: start)
        let result = await controller.begin(
            id: UUID(),
            cancel: { probe.cancel() },
            at: start
        )
        #expect(result == .admitted)

        await controller.update(
            nominal,
            at: start.advanced(by: .seconds(20))
        )
        #expect(probe.count == 1)
    }

    @Test
    func wattageCapFailsClosedWithoutMeasurement() async {
        let limits = ResourceLimits(
            maxContinuousInference: .seconds(20),
            cooldown: .seconds(30),
            maxGPUWatts: 10
        )

        let controller = ResourceController(limits: limits)
        await controller.update(
            ResourceSample(thermal: .nominal, gpuWatts: nil)
        )
        let result = await controller.begin(id: UUID(), cancel: {})
        #expect(result != .admitted)
    }
}

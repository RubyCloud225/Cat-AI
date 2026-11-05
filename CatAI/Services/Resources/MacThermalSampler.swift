import Foundation

/// Supported macOS thermal-pressure monitoring, without root access.
struct MacThermalSampler: Sendable {
    func read() -> ResourceSample {
        let level: ThermalLevel

        switch ProcessInfo.processInfo.thermalState {
        case .nominal:
            level = .nominal
        case .fair:
            level = .fair
        case .serious:
            level = .serious
        case .critical:
            level = .critical
        @unknown default:
            level = .unknown
        }

        // No trusted unprivileged live GPU-wattage source is wired in.
        return ResourceSample(thermal: level, gpuWatts: nil)
    }
}

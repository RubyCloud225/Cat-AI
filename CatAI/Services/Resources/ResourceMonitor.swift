import Foundation

/// Polls macOS thermal state to drive the resource controller.
/// Hardware protection remains the responsibility of macOS.
actor ResourceMonitor {
    private let controller: ResourceController
    private let sampler: MacThermalSampler
    private var monitoringTask: Task<Void, Never>?

    init(
        controller: ResourceController,
        sampler: MacThermalSampler = MacThermalSampler()
    ) {
        self.controller = controller
        self.sampler = sampler
    }

    func start() {
        guard monitoringTask == nil else { return }

        monitoringTask = Task {
            while !Task.isCancelled {
                await controller.update(sampler.read())
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    break
                }
            }
        }
    }

    func stop() {
        monitoringTask?.cancel()
        monitoringTask = nil
    }
}

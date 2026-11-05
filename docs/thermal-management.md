# Cat AI — GPU Power and Thermal Management (P0-005)

**Status:** IMPLEMENTED AS SOURCE FILES; NOT VALIDATED OR WIRED INTO OLLAMA
**Target:** Apple M4 Pro, 24 GB unified memory
**Runtime:** Local Ollama, DeepSeek-R1 14B

## Design

Cat AI's proposed resource controller sits between the inference coordinator and the local Ollama API.

- `MacThermalSampler` reads the publicly supported `ProcessInfo.thermalState` API.
- `ResourceMonitor` polls the sampler once per second while monitoring is active.
- `ResourceController` is actor-isolated and admits at most one logical request.
- Unknown, serious and critical states cancel an active request; only nominal states admit new requests. Fair defers new admissions.
- Serious/critical states trigger a nominal-only recovery interval.
- Optional GPU-wattage limits fail closed when a measurement is absent or invalid.
- The controller does **not** directly change Metal GPU clocks, kernel scheduling, or hardware power limits.

## Initial experimental profiles

| Profile | Continuous inference deadline | Cooldown | GPU wattage cap |
|---|---:|---:|---|
| Quick | 20 seconds | 30 seconds | Disabled |
| Balanced | 40 seconds | 30 seconds | Disabled |
| Extended | 60 seconds | 30 seconds | Disabled |

These values are provisional. They may interrupt valid outputs and are not validated safe hardware thresholds.

## Critical integration limitations

1. **Not connected to Ollama:** This is only policy source code and accompanying tests. No live inference is throttled by this addition.
2. **Cancelled requests:** The current controller clears its logical slot as soon as cancellation is requested. This DOES NOT prove that Ollama has released GPU compute. Before wiring live requests, keep the slot occupied until confirmed completion/termination and test cancellation races.
3. **Duration budget:** The initial implementation has no recovery hold after a duration timeout, so a client could immediately submit another request. Add a mandatory post-timeout cooldown before enabling unattended agent runs.
4. **Power:** The sampler currently returns `gpuWatts: nil`. There is no claim of a measured power budget. If `maxGPUWatts` is set without a provider, admission is denied.
5. **Monitoring:** Start the monitor and await a valid sample before admitting requests. Define lifecycle behaviour during pause, backgrounding, and restart.
6. **Project:** A native SwiftUI target is not yet present or verified; Xcode target membership and Swift 6 compilation remain outstanding.
7. **Safety:** macOS hardware safeguards remain authoritative. Sampling once per second is not guaranteed to catch brief spikes.

## Validation needed (separate permission required)

- Review Swift 6 compiler diagnostics and Swift Testing tests.
- Simulate nominal/fair/serious/critical/unknown state changes and cooldown interruptions.
- Test cancellation exactly once, request identity, stale completion, concurrency and restart.
- Test invalid and missing power readings and configured ceilings.
- Add an Ollama streaming adapter with a cancellation handle connected to the real network request.
- Verify that Ollama stops backend work before another GPU request is admitted.
- Compare idle/active GPU utilisation, power if available, inference throughput, macOS thermal state, memory pressure and fan behaviour.
- Ensure interrupted code generation is visibly incomplete, never presented as success.

## Approval boundary

Source creation was explicitly approved. Compilation, test execution, service changes and live integration were not approved.

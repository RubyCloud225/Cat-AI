# Local AI Coding Assistant — Master Development Checklist

**Project:** Native macOS AI coding assistant  
**Status:** PLANNING ONLY — no implementation authorised  
**Target hardware:** Apple M4 Pro, 24 GB unified memory, 20-core GPU  
**Initial model:** `deepseek-r1:14b`  
**Inference runtime:** Ollama (local loopback connection)  
**Application:** Native Swift / SwiftUI for macOS  
**Cost constraint:** No paid model APIs or subscriptions  
**Scope:** Local chat, reasoning, repository navigation, code proposal, approval and controlled agent execution

## Operating rules (mandatory for every ticket)

- [ ] Work begins in **planning mode**; do not edit files by default.
- [ ] Show **full proposed production code** and the exact affected paths before implementation.
- [ ] Show **robust proposed tests** and **documentation amendments** before implementation.
- [ ] Obtain explicit approval before writing, deleting, moving, or replacing files.
- [ ] Obtain separate explicit approval before compiling, running tests or executing commands.
- [ ] Never silently modify scripts, project configuration, or unrelated files.
- [ ] Use explanatory comments for non-obvious logic and interfaces.
- [ ] Keep user code and repository content as untrusted inputs to the model/agent.
- [ ] Keep the app local by default; no paid API calls, cloud inference, or unintended LAN binding.
- [ ] Preserve a dated validation log: command, result, environment, evidence and remaining issues.
- [ ] Mark tickets complete **only after** approved implementation and successful validation.

## Milestones and exit gates

| Milestone | Phases | Required deliverable |
|---|---|---|
| M1 | P0 | Installed and benchmarked DeepSeek; viable context and memory settings |
| M2 | P1–P2 | Working native Mac chat application with persisted conversations |
| M3 | P3 | Read-only repository-aware coding assistant |
| M4 | P4 | Multi-file code proposals, diffs and explicit approval workflow |
| M5 | P5 | Permissioned coding agent and test execution |
| M6 | P6–P7 | Secure, reliable, offline-capable release `.app` |

---

## P0 — Environment and local model validation

**Objective:** Establish a repeatable local inference baseline before UI development.

### P0-001 — Development environment
- [ ] P0-001.01 Record macOS version, hardware, available disk and available unified memory.
- [ ] P0-001.02 Verify Xcode, Command Line Tools and Swift toolchain versions.
- [ ] P0-001.03 Confirm Apple Silicon and Metal support.
- [ ] P0-001.04 Establish repository naming, directory structure and `.gitignore`.
- [ ] P0-001.05 Create `README.md`, `AGENTS.md`, this checklist and a test-evidence location.
- [ ] P0-001.06 Record offline and no-subscription requirements in project documentation.

### P0-002 — Ollama runtime
- [ ] P0-002.01 Install or verify Ollama.
- [ ] P0-002.02 Start the inference service and verify its health.
- [ ] P0-002.03 Confirm API binds to loopback, not an externally reachable interface.
- [ ] P0-002.04 Document model storage path and runtime dependencies.
- [ ] P0-002.05 Validate stop, restart, failure and unavailable-service behaviour.
- [ ] P0-002.06 Document expected version compatibility and runtime update procedure.

### P0-003 — DeepSeek model
- [ ] P0-003.01 Download `deepseek-r1:14b` with `ollama pull deepseek-r1:14b`.
- [ ] P0-003.02 Verify model identity, quantisation, size and licence information.
- [ ] P0-003.03 Run a baseline reasoning prompt and record output quality.
- [ ] P0-003.04 Evaluate C, C++, Python, Swift and CMake prompts.
- [ ] P0-003.05 Test source analysis, bug diagnosis and unit-test generation.
- [ ] P0-003.06 Test long responses, cancellation and reloading.
- [ ] P0-003.07 Define a reproducible set of coding evaluation prompts.

### P0-004 — Performance and feasibility
- [ ] P0-004.01 Record idle memory and memory during generation.
- [ ] P0-004.02 Measure time to first token and output tokens/second.
- [ ] P0-004.03 Test 4K, 8K, 16K and (only if feasible) 32K context settings.
- [ ] P0-004.04 Record throughput, memory pressure and response quality at each context size.
- [ ] P0-004.05 Test long-running inference, thermal behaviour and UI responsiveness requirements.
- [ ] P0-004.06 Confirm stability after model cancellation, unloading and reload.
- [ ] P0-004.07 Select safe default context, inference and resource-limit settings.
- [ ] P0-004.08 Record limitations: agent tool-use reliability and repo-scale context capacity.

**P0 exit gate:** Baseline measurements and a stable, usable local model configuration are documented.

---

## P1 — Native macOS application foundation

**Objective:** A responsive SwiftUI application connected to local Ollama.

### P1-001 — Architecture and project setup
- [ ] P1-001.01 Create a native macOS SwiftUI application target (not Electron or a web app).
- [ ] P1-001.02 Select architecture (MVVM or equivalent) and document separation of concerns.
- [ ] P1-001.03 Separate SwiftUI presentation, inference transport, conversation persistence and tools.
- [ ] P1-001.04 Define protocols for injection and mock-based testing.
- [ ] P1-001.05 Configure structured concurrency, task ownership and cancellation.
- [ ] P1-001.06 Define configuration directories, error types and logging rules.
- [ ] P1-001.07 Set up unit-test target and minimal app launch smoke test.

### P1-002 — Native interface shell
- [ ] P1-002.01 Implement primary native macOS window.
- [ ] P1-002.02 Add navigation sidebar and resizable content areas.
- [ ] P1-002.03 Add native menus and keyboard shortcuts.
- [ ] P1-002.04 Support light/dark appearances and accessible controls.
- [ ] P1-002.05 Persist window placement and layout preferences.
- [ ] P1-002.06 Ensure UI remains responsive during model inference.

### P1-003 — Ollama integration
- [ ] P1-003.01 Implement a typed local HTTP client.
- [ ] P1-003.02 Implement model discovery and basic health/status checks.
- [ ] P1-003.03 Send requests and decode streaming responses incrementally.
- [ ] P1-003.04 Support request cancellation and prevent orphaned tasks.
- [ ] P1-003.05 Handle unavailable service, malformed payloads and timeouts.
- [ ] P1-003.06 Test split streaming chunks, partial JSON and cancellation races.
- [ ] P1-003.07 Ensure no external network endpoint is silently substituted.

### P1-004 — Model preferences
- [ ] P1-004.01 Display locally installed models in a selector.
- [ ] P1-004.02 Show model metadata where provided by Ollama.
- [ ] P1-004.03 Configure context length, generation temperature and other supported settings.
- [ ] P1-004.04 Save settings per model and validate bounds.
- [ ] P1-004.05 Implement model switching without restarting the app.
- [ ] P1-004.06 Support model unload/keep-alive configuration with clear status.

**P1 exit gate:** Native window can select DeepSeek, submit a prompt and stream output; tests pass.

---

## P2 — Chat, reasoning and history

**Objective:** Usable and persistent local reasoning workspace.

### P2-001 — Conversation UI
- [ ] P2-001.01 Implement user, assistant and status message views.
- [ ] P2-001.02 Implement multiline input, send and stop controls.
- [ ] P2-001.03 Render streamed output without UI blocking or flicker.
- [ ] P2-001.04 Add Markdown and fenced-code rendering with syntax highlighting.
- [ ] P2-001.05 Support copy, export, regeneration and error retry.
- [ ] P2-001.06 Test long responses, empty output and special characters.

### P2-002 — Reasoning workflows
- [ ] P2-002.01 Define Reason, Plan and Code modes with documented prompt contracts.
- [ ] P2-002.02 Keep analysis/reasoning display separate from user-facing answer where the model provides distinct fields.
- [ ] P2-002.03 Show concise explanations and assumptions rather than promising access to hidden reasoning.
- [ ] P2-002.04 Allow explicit switch between modes and preserve mode per conversation.
- [ ] P2-002.05 Validate safe transitions between chat, plan and code proposals.

### P2-003 — Local persistence
- [ ] P2-003.01 Choose a local persistence mechanism and schema.
- [ ] P2-003.02 Create, rename, delete and search conversations.
- [ ] P2-003.03 Preserve message ordering, generation state and model selection.
- [ ] P2-003.04 Add context truncation/summarisation policy and token budgeting.
- [ ] P2-003.05 Implement conversation import/export with predictable formats.
- [ ] P2-003.06 Test restart recovery, migration, data corruption and deletion.
- [ ] P2-003.07 Document where conversation data is stored and how to clear it.

**P2 exit gate:** Reliable local chat with persistence and distinct reasoning/planning workflows.

---

## P3 — Read-only repository integration

**Objective:** Understand project files without modifying them.

### P3-001 — Project access
- [ ] P3-001.01 Open project directories using a native macOS picker.
- [ ] P3-001.02 Limit reads to explicitly approved directory roots.
- [ ] P3-001.03 Implement file-tree navigation with lazy enumeration.
- [ ] P3-001.04 Respect `.gitignore` and configured ignore patterns.
- [ ] P3-001.05 Defend against symlink escapes, path traversal and permission errors.
- [ ] P3-001.06 Support multiple projects and safely revoke project access.
- [ ] P3-001.07 Avoid indexing credentials, secrets and sensitive paths by default.

### P3-002 — Source inspection
- [ ] P3-002.01 Add read-only source viewer, syntax highlighting and line numbers.
- [ ] P3-002.02 Support C, C++, Swift, Python, CMake, JSON, YAML and Markdown.
- [ ] P3-002.03 Support file tabs, selections and file/line context attachments.
- [ ] P3-002.04 Detect binary files and large-file resource limits.
- [ ] P3-002.05 Support safe text search and source navigation.

### P3-003 — Repository understanding
- [ ] P3-003.01 Implement bounded file retrieval and context assembly.
- [ ] P3-003.02 Track source filenames, line numbers and context provenance.
- [ ] P3-003.03 Add chunking and relevance ranking for large repositories.
- [ ] P3-003.04 Add deterministic token-budget enforcement.
- [ ] P3-003.05 Test multi-file reasoning and retrieval accuracy.
- [ ] P3-003.06 Treat repository instructions as untrusted, not permission-granting instructions.
- [ ] P3-003.07 Record context omissions/truncations visibly.

**P3 exit gate:** AI can accurately cite and discuss selected code without modifying files.

---

## P4 — Code proposals, diffs and approval

**Objective:** Generate robust code changes, but apply nothing without consent.

### P4-001 — Proposal generation
- [ ] P4-001.01 Generate a written plan before implementation proposals.
- [ ] P4-001.02 Produce complete proposed production code for affected files.
- [ ] P4-001.03 Produce accompanying tests and documentation changes.
- [ ] P4-001.04 Support new files, refactors, fixes and multi-file changes.
- [ ] P4-001.05 Surface assumptions and incomplete context explicitly.

### P4-002 — Reviewable changes
- [ ] P4-002.01 Produce unified and side-by-side diffs.
- [ ] P4-002.02 Show affected paths and classify create/edit/delete/rename.
- [ ] P4-002.03 Allow approve, reject, edit and request-regeneration actions.
- [ ] P4-002.04 Detect conflicts if on-disk files changed after proposal.
- [ ] P4-002.05 Validate paths, patch hunks and target file hashes.
- [ ] P4-002.06 Stage approved changes safely and apply atomically when feasible.
- [ ] P4-002.07 Implement recovery/rollback for interrupted writes.
- [ ] P4-002.08 Test partial failures and prohibited modification paths.

### P4-003 — Permissions and audit
- [ ] P4-003.01 Default to read-only behaviour.
- [ ] P4-003.02 Require explicit approval for each write action or clearly scoped batch.
- [ ] P4-003.03 Require separate approval for deletes and moves.
- [ ] P4-003.04 Display all targeted paths and operations before confirmation.
- [ ] P4-003.05 Maintain a local audit record of plan, approvals and results.
- [ ] P4-003.06 Reject attempts to cross directory boundaries or override permission prompts.

**P4 exit gate:** A change can be proposed, reviewed, approved, applied and rolled back safely.

---

## P5 — Controlled coding agent and testing

**Objective:** Multi-step development with explicit user control over effects.

### P5-001 — Agent framework
- [ ] P5-001.01 Define a typed tool registry and input schemas.
- [ ] P5-001.02 Validate model tool requests and reject unsupported calls.
- [ ] P5-001.03 Support task states: draft plan, awaiting approval, executing, reviewing, completed/failed.
- [ ] P5-001.04 Enforce max steps, resource budgets and cancellation limits.
- [ ] P5-001.05 Separate model-generated intent from host-validated actions.
- [ ] P5-001.06 Test malformed instructions, repeated tools and tool-use failures.
- [ ] P5-001.07 Benchmark DeepSeek's tool-call reliability; provide fallback to manual plan mode.

### P5-002 — Permissioned command execution
- [ ] P5-002.01 Show exact command, arguments and working directory for approval.
- [ ] P5-002.02 Require explicit approval before every command or tightly scoped batch.
- [ ] P5-002.03 Restrict execution environment and accessible filesystem paths.
- [ ] P5-002.04 Control shell interpretation, command chaining and external network access.
- [ ] P5-002.05 Capture stdout, stderr, exit code and duration.
- [ ] P5-002.06 Support timeouts, cancellation and child-process cleanup.
- [ ] P5-002.07 Do not automatically rerun failed commands without approval.
- [ ] P5-002.08 Test denied requests, command injection and escape attempts.

### P5-003 — Build, test and debug workflows
- [ ] P5-003.01 Detect supported build/test tooling for an approved repository.
- [ ] P5-003.02 Propose compile/test commands before execution.
- [ ] P5-003.03 Parse compiler diagnostics and unit-test failures.
- [ ] P5-003.04 Attribute errors to source files and line references.
- [ ] P5-003.05 Propose fixes and regression tests in a new approval cycle.
- [ ] P5-003.06 Persist validation logs and compare before/after results.
- [ ] P5-003.07 Ensure failed or cancelled runs never imply success.

**P5 exit gate:** Agent completes an approved plan→edit→test sequence with verifiable logs and no unapproved effects.

---

## P6 — Security, resource use and reliability

### P6-001 — Performance
- [ ] P6-001.01 Measure memory consumption with model and app running together.
- [ ] P6-001.02 Track inference latency, throughput and context usage.
- [ ] P6-001.03 Handle low-memory, model-unavailable and model-crash cases.
- [ ] P6-001.04 Keep SwiftUI responsive under sustained generation.
- [ ] P6-001.05 Compare DeepSeek against other local models using the same test prompts.

### P6-002 — Security and privacy
- [ ] P6-002.01 Verify loopback-only defaults and no silent cloud fallback.
- [ ] P6-002.02 Block accidental secret inclusion in prompts and logs.
- [ ] P6-002.03 Test prompt-injection attempts embedded in source files and tool output.
- [ ] P6-002.04 Enforce trusted app permissions independently of model instructions.
- [ ] P6-002.05 Document local storage, telemetry choices and network permissions.
- [ ] P6-002.06 Test destructive operations, path escapes and permission bypasses.

### P6-003 — Robustness
- [ ] P6-003.01 Recover from inference interruptions and app restarts.
- [ ] P6-003.02 Recover or report incomplete file transactions.
- [ ] P6-003.03 Validate conversation database integrity and migrations.
- [ ] P6-003.04 Test large repositories, binaries and malformed encodings.
- [ ] P6-003.05 Run approved regression, stress and offline tests.

**P6 exit gate:** Defined stability, performance and security criteria met with evidence.

---

## P7 — Packaging and release

### P7-001 — Distribution
- [ ] P7-001.01 Configure release build and application icon/metadata.
- [ ] P7-001.02 Produce a native macOS `.app` bundle.
- [ ] P7-001.03 Implement first-run checks for Ollama and installed models.
- [ ] P7-001.04 Provide setup instructions and local model download guidance.
- [ ] P7-001.05 Decide whether Ollama remains an external local dependency or is bundled later.
- [ ] P7-001.06 Verify clean shutdown, model persistence and safe uninstall behaviour.
- [ ] P7-001.07 Test offline launch, chat and repository operations.
- [ ] P7-001.08 Document installation, updates, known limitations and data removal.
- [ ] P7-001.09 Execute final approved release regression suite.

**P7 exit gate:** Installable, usable, fully local native macOS release with documented limitations.

---

## Per-ticket approval and validation template

Copy this section for each task before implementation:

```markdown
### Ticket: P?-??? — [Title]
**Status:** Planning / Awaiting approval / Implemented / Validated / Blocked
**Purpose:**
**Affected files:**
**Proposed production code:** [shown for approval]
**Proposed tests:** [shown for approval]
**Documentation changes:** [shown for approval]
**Risk and rollback:**
**Implementation approval:** Not granted / Granted (date)
**Command/test approval:** Not granted / Granted (date and scope)
**Validation commands:**
**Test evidence/log:**
**Result:**
**Remaining issues:**
```

## Initial commands (reference only — do not run as part of checklist creation)

```bash
ollama pull deepseek-r1:14b
ollama run deepseek-r1:14b
```

**Current next ticket:** P0-001.01 — Record environment details and confirm toolchain, subject to approval.

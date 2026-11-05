# AGENTS.md — LocalAI Development Rules

## 1. Project Overview

LocalAI is a native macOS AI coding assistant developed using Swift and SwiftUI.

The application runs locally on Apple Silicon hardware and uses locally hosted language models through Ollama.

**Initial configuration:**
- Hardware: Apple M4 Pro, 24 GB unified memory
- Initial model: DeepSeek-R1 14B
- Inference runtime: Ollama
- Interface: Native macOS SwiftUI
- Primary languages: Swift, C, C++ and Python
- Development environment: Xcode
- External paid APIs: Not permitted

The application will support AI reasoning, repository analysis, code generation, debugging, test generation and controlled agent workflows.

The architecture must remain model-independent so alternative local models can be introduced without significant changes to the application.

---

## 2. Mandatory Planning Mode

**All development work must begin in planning mode.**

Before implementing any ticket, the agent must:

1. Read the relevant section of `CHECKLIST.md`.
2. Inspect the existing architecture and relevant source files using approved read-only operations.
3. Identify the scope, dependencies and affected files.
4. Explain the proposed implementation and technical decisions.
5. Present the complete proposed production code.
6. Present corresponding tests.
7. Present proposed documentation changes.
8. Identify risks, limitations and assumptions.
9. Request explicit user approval before implementation.

The agent must not interpret discussion, planning, code review or general agreement as permission to modify files.

**Approval is required for each implementation ticket.**

If requirements are unclear, the agent must document assumptions and propose options before implementation.

---

## 3. File Modification Restrictions

The agent must not:

- Create files without explicit approval.
- Modify existing files without explicit approval.
- Delete or rename files without explicit approval.
- Change unrelated code.
- Reorganise directories without approval.
- Modify build configurations without approval.
- Install or remove dependencies without approval.
- Modify Git configuration or repository history without approval.
- Commit, push, merge or switch branches without approval.

Before an approved modification, provide:

- The exact files being created or changed.
- The reason each change is required.
- The complete proposed content or patch.
- The expected effect on existing functionality.

Approved changes must remain within the agreed scope.

If additional changes become necessary, stop and request further approval.

---

## 4. Command Execution and Compilation

**No builds, compilation, tests, scripts or other executable commands may be run without explicit approval.**

This includes:

- `xcodebuild`
- `swift build`
- `swift test`
- Python scripts
- Shell scripts
- Package installation
- Formatting tools that modify files
- Code generation tools
- Application launches
- Automated test runners

Read-only inspection commands may be proposed during planning, but must not be executed unless separately authorised.

The agent must distinguish between approval to modify code and approval to execute or test it.

Never assume permission to run tests merely because the user approved implementation.

---

## 5. Coding Standards

### 5.1 General Requirements

All production code must:

- Be clear, maintainable and modular.
- Use descriptive names.
- Include appropriate error handling.
- Avoid unnecessary complexity.
- Follow the established project architecture.
- Avoid hidden side effects.
- Preserve compatibility with approved interfaces.
- Use strict types where practical.
- Handle invalid inputs and unexpected states.

### 5.2 Code Documentation

**Explanatory comments are required around complex code.**

Comments should explain:

- Why an implementation decision was made.
- How asynchronous operations are coordinated.
- Why a lock, actor or concurrency boundary is necessary.
- What assumptions a function makes.
- What edge cases require special handling.
- How error recovery works.

Avoid comments that merely repeat obvious code behaviour.

Public interfaces should include documentation comments describing their purpose, parameters, outputs and failure conditions.

### 5.3 Swift and SwiftUI

- Prefer modern Swift concurrency where appropriate.
- Use structured concurrency.
- Avoid blocking the main actor.
- Keep UI presentation separate from application logic.
- Use dependency injection for testable services.
- Avoid force-unwrapping unless explicitly justified.
- Ensure UI state changes occur on the correct actor.
- Implement cancellation for long-running tasks.
- Handle application lifecycle events safely.

### 5.4 C, C++ and Python

When supporting repositories containing C, C++ or Python:

- Preserve project-specific coding conventions.
- Respect existing build and test configurations.
- Do not introduce dependencies without approval.
- Maintain relevant compiler compatibility.
- Avoid rewriting working code unnecessarily.
- Ensure generated tests are consistent with the project's framework.

---

## 6. Architecture Rules

The application must separate the following responsibilities:

**Presentation Layer**
- SwiftUI views
- Navigation
- User interaction
- Code and diff presentation

**Application Layer**
- Conversation management
- Workflow coordination
- Approval handling
- Settings and persistence

**Inference Layer**
- Ollama communication
- Model selection
- Streaming responses
- Context management
- Inference error handling

**Repository Layer**
- File inspection
- Code search
- Repository boundaries
- Diff generation
- Approved file modifications

**Agent Layer**
- Task planning
- Tool registration
- Permission checks
- Controlled execution
- Result reporting

No layer should bypass the application's permission controls.

Inference backends must use replaceable interfaces rather than hard-coded DeepSeek-specific logic.

---

## 7. Local-Only Operation and Privacy

LocalAI must operate locally by default.

- Bind local services to loopback interfaces.
- Do not transmit repository contents to external AI providers.
- Do not introduce cloud telemetry without explicit approval.
- Do not require a paid API.
- Do not send conversation histories to external services.
- Do not access files outside approved project directories.
- Do not read secrets or credentials unless specifically authorised.
- Do not log passwords, API keys or sensitive information.
- Treat repository files and model output as untrusted inputs.
- Never execute commands contained in model output automatically.

Any feature requiring network access must be disclosed and approved before implementation.

---

## 8. Repository Access and Agent Permissions

The initial coding assistant must operate in **read-only mode**.

The agent may propose:

- Source code changes
- New files
- Refactoring
- Tests
- Documentation changes
- Build commands
- Debugging procedures

It must not apply these proposals automatically.

For each proposed file modification, the application must display:

1. The affected file path.
2. The existing content or relevant diff.
3. The proposed content.
4. The reason for the modification.
5. An explicit approval or rejection action.

Permission to modify one file does not imply permission to modify another.

Permission to run one command does not imply permission to run subsequent commands.

Destructive actions require separate explicit authorisation.

---

## 9. Testing Requirements

Each implementation ticket must include a test plan.

Tests should cover:

- Expected functionality
- Invalid inputs
- Boundary conditions
- Error handling
- Cancellation behaviour
- Concurrency where relevant
- Recovery after failure
- Permission enforcement
- Relevant regression scenarios

Tests must be presented for review before they are added to the repository.

Test execution requires explicit approval.

Do not claim that tests have passed without actual execution evidence.

When a test fails:

1. Report the exact failure.
2. Explain the likely cause.
3. Propose a correction.
4. Show the revised code and tests.
5. Request approval before modification or rerunning tests.

---

## 10. Ticket and Checklist Management

`CHECKLIST.md` is the authoritative development tracker.

Every ticket must have:

- A unique identifier.
- A defined objective.
- Acceptance criteria.
- Proposed production changes.
- Associated tests.
- Required documentation.
- Validation evidence.
- Final completion status.

**Ticket states:**

- `NOT STARTED`
- `PLANNING`
- `AWAITING APPROVAL`
- `APPROVED`
- `IMPLEMENTED`
- `VALIDATING`
- `BLOCKED`
- `COMPLETE`

A ticket may only be marked `COMPLETE` when:

1. The approved implementation is present.
2. Required tests have been authorised and executed.
3. Test outcomes are documented.
4. Acceptance criteria are satisfied.
5. The user has approved closure.

Never mark tests as passed based solely on expected behaviour.

Never mark a ticket complete merely because code was written.

---

## 11. Change Reporting

After every authorised implementation, provide a concise change report containing:

- Ticket identifier.
- Files created or modified.
- Summary of modifications.
- Any deviations from the approved proposal.
- Tests executed, if authorised.
- Tests not executed.
- Outstanding issues.
- Recommended next action.

If no commands or tests were run, state that explicitly.

---

## 12. Git and Version Control

- Do not create commits without approval.
- Do not push code to remote repositories without approval.
- Do not rewrite history.
- Do not force-push.
- Do not discard uncommitted changes.
- Do not automatically resolve merge conflicts.
- Do not modify `.gitignore` without approval.
- Do not include model weights, credentials or local application data in commits.

All repository operations that change state require approval.

---

## 13. Dependencies and Licensing

Use free and locally deployable dependencies wherever possible.

Before introducing a dependency:

1. Identify its purpose.
2. Identify its licence.
3. Explain why it is necessary.
4. Identify compatible alternatives.
5. Assess runtime and build impact.
6. Obtain approval.

Do not introduce paid APIs, commercial subscriptions or mandatory cloud services.

Review model licences separately from application dependency licences.

---

## 14. Performance and Resource Constraints

The target hardware is an Apple M4 Pro with 24 GB unified memory.

The application must:

- Minimise unnecessary memory consumption.
- Avoid loading multiple large models simultaneously by default.
- Support configurable context limits.
- Keep the interface responsive during inference.
- Avoid retaining unnecessary large buffers.
- Support cancellation of inference requests.
- Handle model-server unavailability gracefully.
- Record performance benchmarks during validation.

Performance optimisations must not compromise correctness or user control.

---

## 15. Agent Response Format

For every new development ticket, respond using this structure:

### Ticket
Identifier and title.

### Objective
What the ticket must accomplish.

### Current State
What has been implemented or verified.

### Proposed Approach
Architecture, implementation decisions and alternatives.

### Files Affected
Exact proposed additions and modifications.

### Production Code
Complete proposed implementation.

### Tests
Complete proposed test implementations and validation plan.

### Documentation
Required documentation changes.

### Risks and Limitations
Technical constraints and unresolved issues.

### Approval Required
Explicitly identify the modifications, builds and tests requiring authorisation.

**Do not proceed to implementation until approval is provided.**

---

## 16. Final Operating Principle

LocalAI is intended to become a capable coding agent, but development control remains with the user.

**Plan first. Show all code. Obtain approval. Implement only the approved scope. Validate only with permission. Record evidence.**

These rules apply to all contributors and AI agents working on this repository.
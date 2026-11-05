# LocalAI — Technical Architecture

**Document:** `docs/architecture.md`  
**Version:** 0.1 — Proposed  
**Platform:** macOS / Apple Silicon  
**Language:** Swift  
**Interface:** SwiftUI  
**Initial inference backend:** Ollama  
**Initial model:** DeepSeek-R1 14B

---

## 1. Purpose

LocalAI is a native macOS application designed to provide locally hosted AI reasoning and software-development assistance.

The application will combine a conversational interface, source-code inspection, repository-aware reasoning, code generation and controlled agent execution.

Its primary objectives are:

1. Run AI inference locally without mandatory cloud services or paid APIs.
2. Provide an efficient native macOS interface for reasoning and software development.
3. Support multiple local language models through a replaceable inference abstraction.
4. Allow AI-assisted analysis of approved local repositories.
5. Separate planning, code generation, modification and execution into independently controlled operations.
6. Maintain strict user approval boundaries for changes to files and execution of commands.
7. Operate within the memory and performance constraints of Apple Silicon hardware.

The initial implementation targets an Apple M4 Pro with 24 GB unified memory.

---

## 2. Architectural Principles

### 2.1 Native-first

The application will use SwiftUI for presentation and Swift for application services.

No embedded browser framework is required for the primary interface.

### 2.2 Local-first

Inference, conversation management and application state will operate locally.

The Ollama service will be accessed through the loopback interface.

External services will not be required for normal operation.

### 2.3 Model independence

Application features must not be tightly coupled to DeepSeek-R1.

Models will be accessed through an inference protocol supporting common operations such as generation, streaming, cancellation and model discovery.

### 2.4 Separation of responsibilities

Presentation, workflow orchestration, inference, repository operations and agent execution must remain distinct.

The user interface must not directly perform repository writes or execute shell commands.

### 2.5 Explicit approval

Proposed changes and executable operations must pass through permission controls before implementation.

The AI model must never grant itself permissions.

### 2.6 Fail-safe operation

Unavailable models, failed network requests, malformed responses and interrupted operations must produce controlled errors rather than unhandled application failures.

---

## 3. System Architecture

```text
┌──────────────────────────────────────────────────┐
│                 LocalAI macOS App                │
│                    SwiftUI                       │
│                                                  │
│  Chat | Reason | Plan | Code | Projects | Review  │
└────────────────────────┬─────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────┐
│                Application Layer                 │
│                                                  │
│  Conversation Manager                            │
│  Workflow Coordinator                            │
│  Application State                               │
│  Model Settings                                  │
│  Approval Coordinator                            │
└──────────────┬──────────────────────┬────────────┘
               │                      │
┌──────────────▼───────────┐ ┌────────▼─────────────┐
│     Inference Layer      │ │ Repository / Agent   │
│                          │ │ Layer                │
│  Inference Protocol      │ │                      │
│  Ollama Adapter          │ │ Repository Reader    │
│  Model Discovery         │ │ Code Search          │
│  Streaming Decoder       │ │ Diff Generator       │
│  Context Manager         │ │ Agent Orchestrator   │
│  Cancellation            │ │ Permission Gateway   │
└──────────────┬───────────┘ └────────┬─────────────┘
               │                      │
┌──────────────▼───────────┐ ┌────────▼─────────────┐
│     Ollama Service       │ │ Local File System    │
│                          │ │                      │
│  DeepSeek-R1 14B         │ │ Approved Repositories│
│  Alternative Models      │ │ Git Metadata         │
│  Local Inference API     │ │ Approved Commands    │
└──────────────────────────┘ └──────────────────────┘
```

All cross-layer interactions must use explicitly defined interfaces.

The model output must be treated as untrusted data, not as an instruction with execution authority.

---

## 4. Project Structure

```text
LocalAI/
├── LocalAI.xcodeproj
├── LocalAI/
│   ├── App/
│   │   ├── LocalAIApp.swift
│   │   └── AppDependencies.swift
│   ├── Views/
│   │   ├── Chat/
│   │   ├── Projects/
│   │   ├── Editor/
│   │   ├── Review/
│   │   └── Settings/
│   ├── ViewModels/
│   │   ├── ChatViewModel.swift
│   │   ├── ProjectViewModel.swift
│   │   └── ReviewViewModel.swift
│   ├── Models/
│   │   ├── ChatMessage.swift
│   │   ├── Conversation.swift
│   │   ├── ProjectReference.swift
│   │   ├── ModelConfiguration.swift
│   │   └── ProposedChange.swift
│   ├── Services/
│   │   ├── Inference/
│   │   │   ├── InferenceService.swift
│   │   │   ├── OllamaInferenceService.swift
│   │   │   └── InferenceError.swift
│   │   ├── Conversations/
│   │   ├── Repository/
│   │   ├── Agent/
│   │   ├── Permissions/
│   │   └── Persistence/
│   └── Resources/
├── LocalAITests/
│   ├── InferenceTests/
│   ├── ConversationTests/
│   ├── RepositoryTests/
│   ├── PermissionTests/
│   └── AgentTests/
├── docs/
│   ├── architecture.md
│   └── validation/
├── AGENTS.md
├── CHECKLIST.md
└── README.md
```

The structure may be extended during implementation, but existing responsibilities must remain separated.

Changes to the agreed architecture require approval.

---

## 5. Presentation Layer

### 5.1 Technology

The presentation layer will use SwiftUI.

Its responsibilities include:

- Rendering conversations.
- Displaying model responses as they stream.
- Managing user navigation.
- Presenting source files.
- Displaying proposed changes.
- Requesting user approval.
- Showing execution and validation results.
- Managing application preferences.

### 5.2 Application navigation

The primary interface will contain:

**Sidebar**

- Conversations
- Projects
- Model selection
- Settings

**Main workspace**

- Chat
- Reasoning
- Planning
- Code inspection
- Change review

**Optional secondary panel**

- Repository explorer
- File context
- Test results
- Agent activity

The layout must support resizable panels and native macOS window behaviour.

### 5.3 UI state

Presentation state should be managed by dedicated view models or equivalent observable state objects.

Long-running operations must not block the main actor.

The UI must show loading, streaming, cancelled and failed states explicitly.

---

## 6. Application Layer

The application layer coordinates user actions and services.

### 6.1 Conversation manager

Responsibilities:

- Create and manage conversations.
- Maintain message ordering.
- Associate conversations with selected models.
- Store user preferences.
- Maintain context boundaries.
- Restore saved conversations.

### 6.2 Workflow coordinator

Controls the application's principal operating modes:

| Mode | Function | File modification |
|---|---|---|
| Reason | Analysis, explanations and debugging | Not permitted |
| Plan | Proposed development approach | Not permitted |
| Code | Generate implementation drafts and tests | Not permitted without approval |
| Review | Inspect proposed changes | Not permitted until approval |
| Execute | Perform specifically approved operations | Permitted within approved scope |

Modes determine the permitted workflow, not the authority of model output.

### 6.3 Approval coordinator

The approval coordinator records decisions on proposed operations.

Approval must be:

- Explicit.
- Associated with a defined operation.
- Limited to specific files or commands.
- Invalidated when the operation changes materially.
- Recorded in a local audit trail.

A previously approved action must not be silently expanded into additional operations.

---

## 7. Inference Layer

### 7.1 Inference abstraction

Inference providers must implement an application-defined protocol.

The initial protocol will support:

- Model discovery.
- Model information retrieval.
- Chat generation.
- Streaming generation.
- Request cancellation.
- Inference configuration.
- Typed errors.

A later implementation may add optional capabilities such as structured output and tool calling.

These capabilities must be detected rather than assumed to exist for every model.

### 7.2 Ollama adapter

The first inference adapter will communicate with Ollama through its local HTTP API.

Default endpoint:

`http://127.0.0.1:11434`

The adapter must:

1. Check service availability.
2. Retrieve available model metadata.
3. Construct valid requests.
4. Stream responses asynchronously.
5. Decode streaming data incrementally.
6. Handle partial network frames.
7. Support cancellation.
8. Map errors into application-defined types.

### 7.3 Initial model

DeepSeek-R1 14B is the initial reasoning model.

Model-specific details such as context limits and generation settings must remain in configuration rather than being embedded into presentation logic.

DeepSeek's behaviour must not define the application's permanent architecture.

### 7.4 Reasoning output

Where a model and inference adapter expose separate reasoning fields, the application may represent them separately from final responses.

The application must not assume that every model exposes reasoning content.

Reasoning presentation must be configurable and must not be confused with approval or execution authority.

### 7.5 Context management

The context manager will:

- Estimate input token requirements.
- Enforce configured context budgets.
- Preserve conversation structure.
- Select repository material relevant to a request.
- Prevent unbounded context growth.
- Report truncation or omitted context.

Context configuration must be benchmarked against available unified memory.

---

## 8. Repository Layer

### 8.1 Repository access

Repository access begins in read-only mode.

The user explicitly selects a project directory using the native macOS file picker.

The application must enforce the selected directory as an access boundary.

### 8.2 File discovery

The repository service will support:

- Directory traversal.
- Supported source-file identification.
- File metadata retrieval.
- Text reading.
- Code search.
- File selection for inference context.

Traversal must handle symlinks, inaccessible paths, large files and binary files safely.

### 8.3 Code understanding

Repository content will initially be provided to the inference model using selected files and bounded text retrieval.

More sophisticated retrieval methods can be introduced after baseline functionality is validated.

A vector database is not required for the initial implementation.

### 8.4 Proposed changes

Generated changes must be represented as explicit proposals.

Each proposal should include:

- Target file.
- Intended operation.
- Existing content reference.
- Proposed content or patch.
- Explanation.
- Applicable tests.
- Approval status.

The repository layer must not execute proposed modifications merely because the model generated them.

---

## 9. Agent Layer

### 9.1 Role

The agent layer will coordinate multi-step development workflows.

Its primary responsibilities include:

- Task decomposition.
- Tool selection.
- Repository-context retrieval.
- Proposal generation.
- Approval requests.
- Controlled action execution.
- Result interpretation.
- Progress reporting.

### 9.2 Tool registry

Agent tools must use explicit typed definitions.

Examples include:

- Read file.
- List directory.
- Search source code.
- Inspect Git status.
- Propose patch.
- Run an approved command.
- Execute approved tests.

Tools must advertise their required permissions.

### 9.3 Execution boundaries

The agent must not be granted unrestricted terminal or file-system access.

Operations must pass through the permission gateway.

Commands must have:

- An explicit executable and arguments.
- An approved working directory.
- Defined environment variables.
- A timeout.
- A cancellation mechanism.
- Captured standard output and standard error.

Command approval must apply to the exact operation submitted.

### 9.4 State transitions

Proposed agent states:

```text
IDLE
  |
  v
PLANNING
  |
  v
AWAITING_APPROVAL
  |
  +---- Rejected ---> CANCELLED
  |
  v
APPROVED
  |
  v
EXECUTING
  |
  +---- Failure ----> FAILED
  |
  v
VALIDATING
  |
  +---- Failure ----> REVIEW_REQUIRED
  |
  v
COMPLETE
```

Additional approvals must be obtained when new file modifications, commands or tests are proposed.

---

## 10. Permissions and Security

### 10.1 Permission model

Permissions will be operation-specific.

Proposed categories:

- Repository read.
- File creation.
- File modification.
- File deletion.
- Command execution.
- Test execution.
- Network access.

Read access is limited to explicitly approved project locations.

Write and execution operations require explicit user approval.

### 10.2 Local-only inference

The Ollama adapter will use a loopback endpoint by default.

Connections to remote inference endpoints must not occur without explicit authorisation.

### 10.3 Sensitive data

The application must avoid automatically reading or submitting:

- Credentials.
- Private keys.
- Environment files containing secrets.
- Authentication tokens.
- Unrelated user directories.

Repository contents and model responses must be considered untrusted.

### 10.4 Audit logging

The application will record:

- Operation type.
- Target resource.
- Approval decision.
- Execution status.
- Timestamp.
- Relevant error results.

Logs must not contain raw credentials or unnecessary sensitive content.

---

## 11. Local Persistence

Initial persistence requirements include:

- Conversations.
- Messages.
- Model preferences.
- Application settings.
- Approved project references.
- Proposed changes.
- Approval and execution records.

The storage mechanism will be selected during implementation.

Possible options include SwiftData, SQLite or structured local files.

The design must support schema evolution, recovery and safe deletion.

Persisted data must remain within the application's local storage boundary unless the user explicitly exports it.

---

## 12. Concurrency and Application Lifecycle

The application will use structured Swift concurrency.

Expected concurrent operations include:

- Streaming inference.
- Repository inspection.
- File search.
- Conversation persistence.
- Agent workflow coordination.
- Approved subprocess execution.

Long-running work must be cancellable where practical.

Closing a window must not create uncontrolled background activity.

The application must handle:

- Ollama unavailable at startup.
- Ollama disconnection during inference.
- Model load failures.
- User-requested cancellation.
- Application termination.
- Recovery of saved state.

The application must never retry a file modification or command execution automatically after an uncertain failure without renewed approval.

---

## 13. Performance and Resource Management

The target device has 24 GB unified memory.

The initial design assumes:

- One active inference model.
- One primary inference stream at a time.
- Bounded conversation context.
- Incremental streamed-response processing.
- Lazy repository loading.
- Limits on file and output sizes.
- No unnecessary duplication of large source buffers.

Performance testing will establish:

- Time to first token.
- Tokens per second.
- Memory consumption.
- Response to memory pressure.
- UI responsiveness.
- Context-length limits.
- Model recovery behaviour.

The application should prioritise predictable operation over maximising context length.

---

## 14. Error Handling

Errors must be represented explicitly rather than hidden.

Initial categories include:

- Inference service unavailable.
- Model not installed.
- Invalid model configuration.
- Network timeout.
- Streaming decode failure.
- Request cancelled.
- Context limit exceeded.
- Repository access denied.
- File changed since proposal.
- Patch conflict.
- Operation not approved.
- Command execution failure.
- Persistence failure.

The interface must communicate failures in understandable terms without exposing unnecessary internal details.

---

## 15. Testing Architecture

### 15.1 Unit tests

Unit tests will cover:

- Request construction.
- Response decoding.
- Model metadata parsing.
- Conversation management.
- Context budgeting.
- Permission decisions.
- Agent state transitions.
- Error classification.

### 15.2 Integration tests

Integration tests will cover:

- Mocked Ollama HTTP responses.
- Streaming and cancellation.
- Repository access controls.
- Patch proposal and approval workflows.
- Persistence and recovery.
- Approved command execution.

### 15.3 Security tests

Security tests must exercise:

- Path traversal.
- Symlink escapes.
- Unapproved file writes.
- Unapproved commands.
- Prompt injection from repository files.
- Malformed model output.
- Excessive resource consumption.

### 15.4 Validation policy

No tests may be executed without authorisation.

Results must be captured against the relevant checklist ticket.

A test is not considered passed merely because implementation appears correct.

---

## 16. Build and Distribution

The initial application will be built through Xcode.

The target is a native macOS `.app` bundle.

The initial release may depend on an independently installed Ollama runtime.

Future versions may investigate bundling or replacing the inference runtime.

Such a change must not require rewriting the interface or agent services.

Distribution signing and notarisation will be evaluated before external release.

---

## 17. Development Dependencies

The initial architecture favours Apple's standard frameworks:

- SwiftUI
- Foundation
- Swift Concurrency
- URLSession
- FileManager
- XCTest or Swift Testing

Additional dependencies require review of:

- Licence.
- Necessity.
- Security.
- Maintenance.
- Memory footprint.
- Compatibility with Apple Silicon.

Avoid dependencies that duplicate capabilities already available through native frameworks without a demonstrated advantage.

---

## 18. Architecture Decisions Requiring Validation

The following decisions remain open:

| Decision | Initial preference | Validation stage |
|---|---|---|
| Persistence | SwiftData or SQLite | P2 |
| Source highlighting | Native/editor component | P3 |
| Context retrieval | Bounded file search | P3 |
| Git integration | Read-only status initially | P3 |
| Patch representation | Unified diff plus structured proposal | P4 |
| Agent tool protocol | Internal typed registry | P5 |
| Command isolation | Restricted subprocess model | P5 |
| Model benchmarking | DeepSeek-R1 14B baseline | P0/P6 |
| Ollama packaging | External runtime initially | P7 |

These decisions should be finalised through their implementation tickets rather than being assumed complete.

---

## 19. Development Milestones

| Milestone | Phase | Completion condition |
|---|---|---|
| M1 | P0 | Local inference validated |
| M2 | P1–P2 | Working native reasoning application |
| M3 | P3 | Repository-aware read-only assistant |
| M4 | P4 | Approved code modifications |
| M5 | P5 | Controlled multi-step coding agent |
| M6 | P6–P7 | Tested native release |

Each milestone must have documented evidence before closure.

---

## 20. Architectural Constraints

The following constraints are mandatory:

1. The interface must remain a native macOS application.
2. Normal AI inference must not require cloud services.
3. No paid inference API may be required.
4. Model backends must remain replaceable.
5. No model-generated file changes may be applied without approval.
6. No model-generated commands may execute without approval.
7. No background autonomous execution may occur without user authorisation.
8. The application must remain responsive during inference.
9. Repository access must be bounded to approved locations.
10. Tests and builds require separate authorisation during development.

---

## 21. Summary

LocalAI will use a modular native macOS architecture combining SwiftUI, Swift application services and local model inference through Ollama.

The architecture separates:

- User interaction.
- Conversation and workflow coordination.
- Inference.
- Repository inspection.
- Proposed code changes.
- Approval and permission controls.
- Controlled agent execution.
- Persistence and validation.

This separation is intended to support future model replacement, safe coding workflows and incremental development without requiring a major redesign.

**Operating principle:** Plan first. Generate visibly. Approve explicitly. Execute within scope. Validate with evidence.
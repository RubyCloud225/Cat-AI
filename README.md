# LocalAI

**A native macOS coding and reasoning assistant powered by locally hosted AI models.**

LocalAI is an open-source-oriented, privacy-first desktop application designed to provide AI-assisted software development without relying on paid APIs, cloud inference services or subscriptions.

The application is built using Swift and SwiftUI, with locally hosted language models accessed through Ollama.

The initial model is DeepSeek-R1 14B, with an architecture designed to support other locally installed models in the future.

> **Development status:** Initial development — P0 environment setup. The native application has not yet been implemented.

---

## 1. Project Objectives

LocalAI aims to provide a locally hosted AI coding environment capable of:

- Reasoning about technical problems and software architecture.
- Understanding C, C++, Python, Swift and other programming languages.
- Exploring and analysing local code repositories.
- Generating production code, tests and documentation.
- Identifying bugs and proposing corrections.
- Reviewing proposed changes before implementation.
- Executing approved commands and tests.
- Managing multi-step development tasks through a controlled coding agent.

The application will prioritise reasoning quality, transparency, local execution and user control.

### Core principles

1. **Local-first:** AI inference and application data remain on the user's machine.
2. **No paid inference:** No subscription or commercial API is required.
3. **Native macOS:** The interface uses SwiftUI rather than a browser-based framework.
4. **Model-independent:** Compatible local models can be selected without replacing the application.
5. **Approval-based:** File modifications and command execution require explicit user approval.
6. **Planning-first:** Development tasks begin with a proposed plan, implementation and validation strategy.

---

## 2. Target Hardware

The initial development and validation environment is:

| Component | Specification |
|---|---|
| Computer | MacBook Pro |
| Processor | Apple M4 Pro |
| GPU | 20-core integrated Apple GPU |
| Unified memory | 24 GB |
| Operating system | macOS |
| Development environment | Xcode |
| Programming language | Swift |
| User interface | SwiftUI |
| Inference runtime | Ollama |
| Initial AI model | DeepSeek-R1 14B |

Apple Silicon uses unified memory shared between the CPU, GPU and operating system.

Model size, context length and application memory consumption must therefore be considered together.

---

## 3. Technical Architecture

LocalAI follows a modular architecture separating the native application interface, inference services, repository management and agent execution.

```text
┌──────────────────────────────────────────┐
│              LocalAI App                 │
│             SwiftUI / macOS              │
│                                          │
│  Chat | Reason | Plan | Code | Projects  │
└─────────────────────┬────────────────────┘
                      │
┌─────────────────────▼────────────────────┐
│           Application Services           │
│                                          │
│ Conversation | Settings | Permissions    │
│ Workflow State | Local Persistence       │
└──────────────┬───────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼────────┐ ┌─────▼──────────────────┐
│ Inference     │ │ Repository & Agent     │
│ Services      │ │ Services               │
│               │ │                        │
│ Model API     │ │ File Access            │
│ Streaming     │ │ Code Search            │
│ Context       │ │ Diff Generation        │
│ Cancellation  │ │ Approved Execution     │
└──────┬────────┘ └────────────────────────┘
       │
┌──────▼───────────────────────────────────┐
│              Ollama                      │
│                                          │
│ DeepSeek-R1 14B / Alternative Models     │
│ Local Apple Silicon Inference            │
└──────────────────────────────────────────┘
```

The inference runtime operates as a separate local service.

LocalAI communicates with Ollama through its local HTTP API. The application does not require a cloud model endpoint.

---

## 4. Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Desktop interface | SwiftUI | Native macOS application |
| Application logic | Swift | State management and workflows |
| Concurrency | Swift Concurrency | Asynchronous inference and tasks |
| Model runtime | Ollama | Local model execution |
| Initial model | DeepSeek-R1 14B | Coding and reasoning |
| Communication | Local HTTP API | Application-to-model communication |
| Persistence | Local storage | Conversations and settings |
| Code integration | FileManager / Git | Repository inspection and version control |
| Testing | XCTest / Swift Testing | Application validation |

Dependencies will be evaluated individually for licensing, security and resource usage.

---

## 5. Local Model Setup

### Prerequisites

- Apple Silicon Mac
- macOS with a compatible Swift/Xcode toolchain
- Ollama installed
- Sufficient free storage for the chosen model
- Adequate unified memory for model inference

### Install Ollama

If Homebrew is available:

```bash
brew install ollama
```

Alternatively, use the official Ollama macOS installer.

### Start Ollama

For a command-line installation, start the local inference service:

```bash
ollama serve
```

If the Ollama application or another service instance is already running, a second server process is unnecessary.

### Download DeepSeek

```bash
ollama pull deepseek-r1:14b
```

The quantised model download is approximately 9 GB.

### Verify the model

```bash
ollama list
```

### Run a local inference session

```bash
ollama run deepseek-r1:14b
```

The model runs locally through Ollama. A paid API key is not required.

### Local API

Ollama normally exposes its API at:

```text
http://127.0.0.1:11434
```

LocalAI will use this endpoint by default.

Actual service availability and network binding will be verified during P0-002.

---

## 6. Planned Application Features

The following features are planned and should not be considered implemented until their corresponding development tickets are completed.

### 6.1 Chat and Reasoning

- Native chat interface.
- Streaming AI responses.
- Markdown and code rendering.
- Reasoning-oriented interaction.
- Conversation history.
- Configurable generation settings.
- Request cancellation.

### 6.2 Workflow Modes

**Reason Mode**

Analyse questions, algorithms, errors and architectural decisions.

**Plan Mode**

Produce implementation plans, identify affected files and propose tests without modifying code.

**Code Mode**

Generate source code, refactoring proposals, tests and documentation for review.

### 6.3 Repository Workspace

- Open and inspect local repositories.
- Display directory structures.
- Read supported source files.
- Search repository contents.
- Provide selected files as model context.
- Display source references.
- Handle large repositories with controlled context retrieval.

### 6.4 Code Review and Modification

- Propose single-file and multi-file changes.
- Present file diffs.
- Review generated tests.
- Approve or reject modifications.
- Detect conflicting edits.
- Preserve unapproved files.
- Maintain change records.

### 6.5 Controlled Coding Agent

The planned agent will support multi-step software development workflows.

Its responsibilities will include:

- Analysing assigned tasks.
- Preparing implementation plans.
- Selecting permitted tools.
- Proposing source changes.
- Requesting approval.
- Executing approved operations.
- Reviewing test results.
- Reporting outcomes.

The agent must not operate with unrestricted file-system or terminal permissions.

---

## 7. Development Roadmap

| Phase | Description | Status |
|---|---|---|
| P0 | Environment and local model validation | In progress |
| P1 | Native macOS application foundation | Not started |
| P2 | Chat and reasoning environment | Not started |
| P3 | Repository and coding integration | Not started |
| P4 | Code generation and approval system | Not started |
| P5 | Coding agent and controlled execution | Not started |
| P6 | Performance, safety and reliability | Not started |
| P7 | Packaging and release | Not started |

Detailed implementation tickets and acceptance criteria are maintained in `CHECKLIST.md`.

---

## 8. Proposed Repository Structure

```text
LocalAI/
├── LocalAI.xcodeproj
├── LocalAI/
│   ├── App/
│   ├── Views/
│   ├── ViewModels/
│   ├── Models/
│   ├── Services/
│   │   ├── Inference/
│   │   ├── Repository/
│   │   └── Agent/
│   └── Resources/
├── LocalAITests/
│   ├── InferenceTests/
│   ├── RepositoryTests/
│   └── AgentTests/
├── docs/
│   ├── architecture.md
│   └── validation/
├── AGENTS.md
├── CHECKLIST.md
└── README.md
```

This directory structure is proposed and will be established during the approved implementation of P0-001.

---

## 9. Development and Approval Workflow

Development follows the rules defined in `AGENTS.md`.

Every implementation ticket follows this sequence:

1. **Planning:** Review requirements, architecture and dependencies.
2. **Proposal:** Present production code, tests and documentation.
3. **Approval:** Obtain explicit permission to modify files.
4. **Implementation:** Apply only approved changes.
5. **Validation approval:** Obtain permission to build or run tests.
6. **Validation:** Execute approved checks and record results.
7. **Review:** Present evidence and outstanding issues.
8. **Closure:** Mark the ticket complete only after acceptance.

Approval to implement code does not automatically authorise compilation or test execution.

---

## 10. Testing Strategy

The project will use automated testing appropriate to the implemented components.

Planned coverage includes:

- Inference API communication.
- Response streaming and cancellation.
- Error handling.
- Model selection.
- Conversation persistence.
- Repository access boundaries.
- Code diff generation.
- Permission enforcement.
- Agent state transitions.
- Command execution restrictions.
- Application lifecycle and recovery.
- Performance and memory usage.

Tests must be reproducible, with evidence recorded against the relevant development ticket.

A test is not considered passed until it has been executed successfully.

---

## 11. Privacy and Security

LocalAI is intended to operate without mandatory cloud connectivity.

The application must:

- Keep inference local by default.
- Avoid paid or cloud-based model dependencies.
- Require explicit approval for network-dependent features.
- Restrict repository access to authorised locations.
- Treat model output and repository content as untrusted.
- Prevent automatic execution of model-generated commands.
- Protect local conversation data and application settings.
- Avoid recording passwords, credentials or sensitive information in logs.

Local execution does not automatically guarantee safe operation. File permissions, agent tools and network boundaries must be enforced independently of the model.

---

## 12. Performance Considerations

The target hardware has 24 GB of unified memory.

The initial implementation will prioritise:

- A single active inference model.
- Configurable context windows.
- Responsive SwiftUI interaction.
- Asynchronous inference.
- Cancellation of long-running requests.
- Controlled conversation history.
- Memory-pressure handling.
- Performance benchmarking.

The feasibility of larger models and context windows will be determined through actual measurements rather than assumptions.

---

## 13. Current Development Status

**As of 5 November 2026:**

- DeepSeek has been installed locally by the developer.
- The initial model selection is DeepSeek-R1 14B.
- Native SwiftUI has been selected for the application interface.
- Ollama has been selected as the initial inference runtime.
- The development checklist has been prepared.
- `AGENTS.md` development rules have been approved.
- The SwiftUI application has not yet been implemented.
- Model performance and inference API integration have not yet been validated.

The next development activity is to complete P0 environment validation and proceed to P0-002, Ollama service configuration.

---

## 14. Licence

The application's distribution licence has not yet been selected.

LocalAI source-code licensing must be decided before public distribution.

Third-party dependencies and AI model weights remain subject to their respective licences.

---

## 15. Project Principle

**Reason locally. Plan visibly. Review changes. Execute only with approval.**

LocalAI is designed to give developers the benefits of AI-assisted programming while retaining control over their source code, development environments and execution workflows.
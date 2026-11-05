Cat AI — Command Reference
File: COMMANDS.md
Project: Cat AI (native macOS / SwiftUI coding assistant)
Status: Proposed, awaiting approval to add to the repository
Environment: Apple M4 Pro, 24 GB unified memory; Ollama 0.40.14; deepseek-r1:14b (Q4_K_M)
1. Operating rules
- Planning mode is the default. Commands in this document are examples for the developer to run, not authorisation for an AI agent to execute them.
- Read-only inspection may be suggested, but the agent must obtain permission before executing commands itself.
- State-changing commands, including downloads, installs, edits, deletes, builds, tests, Git mutations and process termination, require explicit approval for the specific operation.
- Never automatically execute commands proposed by the model. Display the executable, arguments, working directory and expected effects for approval.
- Do not claim a check has passed until its output is captured. Record validation against the relevant ticket in CHECKLIST.md.
- Keep Ollama on loopback (127.0.0.1) unless an external network connection is separately approved.
2. Environment inspection (read-only)
sw_vers
uname -m
sysctl -n hw.memsize
xcodebuild -version
xcode-select -p
swift --version
system_profiler SPDisplaysDataType
These identify macOS, architecture, RAM, Xcode, Swift and GPU information.
3. Ollama — service and model inspection
These commands inspect the local runtime without starting inference:
ollama --version
ollama list
ollama show deepseek-r1:14b
curl --fail --silent --show-error http://127.0.0.1:11434/api/version
curl --fail --silent --show-error http://127.0.0.1:11434/api/tags
lsof -nP -iTCP:11434 -sTCP:LISTEN
du -sh ~/.ollama/models
Expected for the initial Cat AI environment: Ollama 0.40.14, model deepseek-r1:14b, and a listener on 127.0.0.1:11434. The model's advertised context limit is not an approved runtime context length; benchmark practical context settings before selecting them.
Start inference service (state-changing: requires approval)
ollama serve
Do not start a second instance if Ollama is already running (for example through its macOS app or a launch service). Use the existing local service.
Download or update the model (network + disk changes: requires approval)
ollama pull deepseek-r1:14b
Interactive test (runs inference: requires approval)
ollama run deepseek-r1:14b
Exit the interactive prompt using /bye.
View active loaded models (read-only)
ollama ps
4. Ollama — reproducible API validation
GET version and model list: see Section 3.

Generate a test response (runs inference: requires approval):
curl --fail --silent --show-error \
  http://127.0.0.1:11434/api/chat \
  -H 'Content-Type: application/json' \
  -d '{
    "model": "deepseek-r1:14b",
    "messages": [{"role": "user", "content": "Reply with exactly: Cat AI ready"}],
    "stream": false,
    "options": {"num_ctx": 4096}
  }'
Inspect the resulting JSON rather than assuming it will contain exactly the requested words. Log the model, configured context, observed result and any errors. Ollama API responses may include timing and token-count metrics; verify fields in the installed version before automating extraction.
Context experiments (runs inference: requires approval)
For P0-003/P0-004, repeat a fixed benchmark prompt with explicit num_ctx values such as 4096 and 8192. Larger contexts should only be attempted after measuring memory pressure. Do not infer that a 131,072-token model metadata limit fits in 24 GB unified memory.
5. Process and connection diagnostics
Inspect listening sockets and processes (read-only):
lsof -nP -iTCP:11434 -sTCP:LISTEN
pgrep -fl ollama
Service restart testing (state-changing: requires approval): close or stop Ollama using the actual installation method, verify that the API is temporarily unavailable, restart it using the same method, and check /api/version again. Avoid indiscriminate killall or pkill operations.
6. Xcode and Swift
Inspection (read-only):
xcodebuild -version
xcode-select -p
swift --version
Open Xcode (launches application: requires approval when performed by agent):
open -a Xcode
List available schemes after a project exists (read-only project inspection):
xcodebuild -list -project CatAI.xcodeproj
CatAI.xcodeproj is a proposed project filename; replace it with the actual approved project path. Project structure and scheme names are not yet verified.

Future build command (build writes artifacts; requires separate approval):
xcodebuild -project CatAI.xcodeproj -scheme CatAI -configuration Debug build
Future test command (executes tests and writes artifacts; requires separate approval):
xcodebuild -project CatAI.xcodeproj -scheme CatAI test -destination 'platform=macOS'
These are templates only. Confirm the project file, scheme, destination and signing configuration before running them. Approval to implement code is not approval to build or test it.
7. Repository inspection and Git
Read-only inspections:
pwd
find . -maxdepth 2 -type f | sort | head -100
git status --short
git branch --show-current
git diff --stat
git diff --check
git diff --check only inspects changes; it does not validate the code. Do not use git clean, git reset --hard, commits, pushes, branch changes or rebases without explicit approval.
8. Validation record conventions
Store test evidence under an agreed location, such as:
Cat AI/
├── CHECKLIST.md
├── COMMANDS.md
└── docs/
    └── validation/
        ├── P0-003_R02_CPP_Reasoning.md
        ├── P0-003_R03_Architecture.md
        └── P0-003_R04_Instruction_Following.md
The example paths are proposed, not confirmed as existing files.

Each record should capture:
- Ticket ID, date, model ID/tag, Ollama version, host hardware and context configuration.
- Exact prompt or fixture and expected outcome.
- Output or a reference to the retained output.
- Technical assessment, scoring rubric and observed limitations.
- Whether any command, compilation or tests were actually executed.
- Status: NOT STARTED, PLANNING, AWAITING APPROVAL, APPROVED, IMPLEMENTED, VALIDATING, BLOCKED or COMPLETE.
Results established so far
Item	Evidence-based status
P0-002: Ollama service, API, model discovery, loopback, disk footprint	Verified on 2026-11-05
P0-002: shutdown/restart	Not yet independently evidenced in the shared results
P0-003 R02: basic C++ data-race reasoning	7/7 qualitative criteria
P0-003 R03: architecture design, first attempt	48/100 qualitative review; below threshold
P0-003 R03-B: revision after explicit critique	50/100 qualitative review; below threshold
P0-003 R04: bounded Swift implementation/instruction-following	Not started


Scores are human reviews of model output, not compilation results or standardised benchmark scores.
9. Prohibited shortcuts
Do not use the following as routine cleanup or development shortcuts:
sudo rm -rf <directory>
git reset --hard
git clean -fdx
curl <untrusted-script> | sh
These are illustrative unsafe patterns, not commands to run. Never bypass filesystem protections or execute model-proposed shell scripts automatically.
Operating principle: Plan first. Show exact commands and code. Obtain approval. Execute only approved operations. Record evidence.
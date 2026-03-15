# AGENTS.md - Agentic Coding Guidelines

This repository is a multi-agent software development framework. When working on projects created by this framework, follow these guidelines.

---

## Project Structure

Projects developed by the microco team follow this directory structure:

```
project_root/
├── progress/
│   └── progress_log.md    # PM maintains progress tracking
├── docs/
│   ├── plan_doc.md        # Planner's requirements document
│   ├── arch_overview.md   # Architect's technical overview
│   └── review_notes.md    # Code review records
├── plans/
│   └── plan_<module>.md   # Detailed development plans
├── scripts/
│   └── setup_env.sh       # Environment setup scripts
├── tests/
│   ├── test_cases_*.md    # QA test cases
│   └── bug_report_*..md    # Defect reports
└── src/                   # Project source code
```

---

## Build / Lint / Test Commands

Since this framework supports multiple project types, commands depend on the tech stack defined in `arch_overview.md`. Common patterns:

### Python Projects
```bash
# Single test
pytest tests/test_file.py::test_function -v

# Lint
ruff check src/
ruff format src/

# Type check
mypy src/

# Build/format
black src/
isort src/
```

### Node.js Projects
```bash
# Single test (Jest)
npx jest --testPathPattern="test_file" --testNamePattern="test_name"

# Lint
npm run lint

# Type check
npm run typecheck
```

### All Projects
- Always check `package.json` / `pyproject.toml` / `Makefile` for available scripts
- Run lint/typecheck before committing
- Run full test suite before marking tasks complete

---

## Code Style Guidelines

### General Principles
- Write self-documenting code with clear variable/function names
- Keep functions small and focused (single responsibility)
- Add type annotations where supported
- Handle errors explicitly, avoid silent failures

### Naming Conventions
- **Files**: `snake_case.py`, `kebab-case.js`, `PascalCase.ts`
- **Classes**: `PascalCase` (e.g., `UserService`)
- **Functions/Methods**: `snake_case` (Python), `camelCase` (JS/TS)
- **Constants**: `UPPER_SNAKE_CASE`
- **Interfaces**: `IPascalCase` or just `PascalCase`

### Imports
- Group: standard library → third-party → local
- Sort alphabetically within groups
- Use absolute imports when possible
- Avoid wildcard imports (`from x import *`)

### Types
- Prefer explicit types over `any` / `unknown`
- Use interfaces/types for object shapes
- Generic types for reusable utilities

### Error Handling
- Use custom error classes for domain errors
- Log errors with context before re-raising
- Never expose raw exceptions to users
- Example: `raise CustomError("message") from original`

### Comments
- Explain *why*, not *what*
- Document public APIs with docstrings
- TODO comments must include issue/task reference

---

## Agent Collaboration Rules

### Communication Flow
- **ALL** inter-agent communication must go through PM
- PM passes raw information (no interpretation)
- Agents work in sequence per workflow

### Workflow Stages
1. **PM** receives user requirements → assigns to **Planner**
2. **Planner** outputs `./docs/plan_doc.md` → user confirms → assigns to **Architect**
3. **Architect** outputs `./docs/arch_overview.md` → user confirms → **Ops** starts env setup in parallel with **Architect** creating plan files
4. **Coder** receives plan files → writes code to `./src/` → self-tests → reports to PM
5. **PM** assigns to **Reviewer** → Reviewer reviews code → outputs `./docs/review_notes.md` → reports to PM
6. **PM** assigns to **QA** → QA writes tests, verifies, reports to PM
7. **PM** delivers to user

### Agent Constraints
- **PM**: No code, no technical docs, only information routing
- **Planner**: No technical feasibility assessment
- **Architect**: No implementation code, only design
- **Coder**: No env setup, follows plan files exactly
- **Ops**: No business code, only infrastructure scripts
- **QA**: No code modification, only testing and reporting
- **Reviewer**: No code modification, only reviewing and reporting

---

## Important Reminders

- Wait for user confirmation at review nodes (plan_doc, arch_overview)
- All work products must be written to disk (not just displayed)
- File paths must be exact per the directory structure
- Report completion in the format specified in each agent's prompt.txt
- Never bypass PM for direct communication between agents
# A `uv` Project Template

A research-grade Python project template using `uv` for dependency management.

---

## Prerequisites

- `uv` installed at the system level (one-time setup — replace with the desired version):

```bash
UV_VERSION=0.10.8 curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh
```

See [uv installation docs](https://docs.astral.sh/uv/getting-started/installation/) for other methods.

- **VS Code** with the [Claude Code extension](https://marketplace.visualstudio.com/items?itemName=Anthropic.claude-code) installed (if using Claude Code — see below).

---

## Creating a New Project from This Template

### 1. Create your repo from the template

Click **"Use this template"** on the [`uv-project-template`](https://github.com/your-org/uv-project-template) GitHub page,
then select "Create a new repository". Choose your organisation, name the repo, and clone it locally:

```bash
git clone git@github.com:your-org/your-new-project.git
cd your-new-project
```

### 2. Rename the project

Find and replace `my_prj` with your project name in:

- `pyproject.toml` — `[project] name`, `[project.scripts]`, `[tool.coverage.run] source`,
  `[tool.ruff.lint.isort] known-first-party`
- `Makefile` — `python_folders`
- `.github/workflows/ci.yml` — `python_folders` variable (if present)

### 3. Rename the Python packages

Replace `my_prj` and `my_prj_config` with your actual package folder names everywhere they
appear (same files as above), and rename the corresponding directories on disk.

### 4. Configure secrets and environment

Copy `.env.example` to `.env` and fill in your API keys and config:

```bash
cp .env.example .env
```

Never commit `.env` — it is already in `.gitignore`.

### 5. Set up VS Code settings

Copy the default VS Code settings into place:

```bash
cp .vscode/settings.json.default .vscode/settings.json
```

`settings.json` is gitignored so local customisations stay local.
`settings.json.default` is the tracked canonical reference — edit that
if you want to change the shared defaults for the project.

### 6. Bootstrap the environment

```bash
make dev
```

This pins Python 3.12.10, resolves dependencies, and creates `.venv`.

### 7. Set up Claude Code (recommended)

If you are using Claude Code to develop this project, do this **before your first Claude Code
session** — not after. The payoff is that Claude Code will respect your conventions from the
first line of code it writes.

**a. Write `CLAUDE.md`** at the project root. This file is read automatically by Claude Code
at the start of every session. Keep it under ~200 lines — it is navigation, not content.
It should contain:

- Project identity (one short paragraph: what it is, how it is deployed)
- Stack and tooling invariants (Python version, `uv` conventions, key deps)
- Make targets (point Claude Code at `make test`, `make all-tests`, etc.)
- Package layout and module ownership rules (what belongs in which file)
- Any non-negotiable design invariants (factory patterns, ownership rules, etc.)
- Git workflow (branch naming, commit message format)
- Testing conventions (mock boundary, coverage gate, test style)
- Current work-package or milestone status (updated manually as work progresses)
- Pointers to `docs/project/` reference documents

Detailed specs belong in `docs/project/`, not in `CLAUDE.md` itself. See any project that
uses this template for a concrete example.

**b. Populate `docs/project/`** with reference documents before writing any code:

```
docs/
└── project/
    ├── architecture.md        # system overview, component relationships
    ├── design_decisions.md    # rationale for key design choices
    ├── testing_philosophy.md  # global test conventions, fixture signatures
    ├── types_reference.md     # design intent for the types/models module
    ├── wp1_spec.md            # WP description + issue acceptance criteria + tests
    ├── wp2_spec.md            # (repeat for each work package)
    └── ...
```

Each `wpN_spec.md` combines the work-package description, its issue acceptance criteria, and
the relevant test cases into a single file Claude Code reads at the start of that WP's session.

**c. Create module stubs** for all files you know will exist, each with a docstring describing
its role. Claude Code extends existing files rather than inventing structure:

```python
"""
services.py
-----------
ScribeService, IntakeClassifier, RagStore, ProposalIngestor, Controller.

Implementation begins in WP2. See docs/project/architecture.md.
"""
```

**d. Open VS Code at the project root**, start a Claude Code session, and begin with a
*reading* prompt — not a writing one:

```
Read CLAUDE.md, then docs/project/architecture.md.
Confirm your understanding of the module ownership rules and the
non-negotiable invariants. Do not write any code yet.
```

### 8. Commit the scaffold

```bash
git add .
git commit -m "chore: rename template and add project scaffold"
git push
```

Include `CLAUDE.md`, `docs/project/`, and all stub files in this initial commit.

---

## Day-to-Day

| Command | Description |
|---|---|
| `make dev` | Create/update the `.venv` and sync all dependencies |
| `make test` | Run unit tests — fast, no external deps, safe to run before every commit |
| `make all-tests` | Run the full suite: unit + integration (`--slow`) + workflow tests |
| `make lint` | Run ruff + mypy |
| `make fix-ruff` | Auto-fix ruff issues |
| `make verify-lock` | Check lockfile is consistent with `pyproject.toml` |
| `make wheel` | Build a distributable wheel |

CI runs `make lint` and `make all-tests` on every pull request. `make test` is for local
development; `make all-tests` is the CI gate.

### Adding a dependency

1. Add it to `[project] dependencies` (runtime) or `[dependency-groups] dev` (dev/test only)
   in `pyproject.toml`
2. Run `make dev` to resolve and sync
3. Commit `pyproject.toml` and `uv.lock` together in a single commit

Never install packages directly with `pip` or `uv pip` — always go through `pyproject.toml`.

### Coverage

The coverage gate is set in `[tool.coverage.report] fail_under` in `pyproject.toml`.
Unit tests alone (via `make test`) must clear this threshold. If a file is genuinely
untestable (CLI entry points, generated stubs), add it to `[tool.coverage.run] omit`
with an explanatory comment rather than lowering the threshold.

---

## Git Workflow

One issue per branch, one branch per pull request:

```
GitHub issue → feature branch → pull request → main
```

**Branch naming:** `feat/<issue-id>-<short-slug>`
e.g. `feat/wp1-t2-entity-factory-registry`

**Commit messages:** `<issue-id>: <imperative summary>`
e.g. `WP1-T2: implement entity factories with UUID assignment`

CI runs on every pull request. Do not merge with a failing pipeline.
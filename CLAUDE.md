# [Project Name] — Claude Code Context

[One paragraph: what this project does and how it is deployed or used.
Replace this with the real description before your first Claude Code session.]

See `docs/project/architecture.md` for the full architecture reference.

---

## Stack and Tooling

- **Python** 3.12.10 — pinned via `uv python pin`
- **Package manager** — `uv` exclusively; never `pip install`, never `requirements.txt`
- **Versioning** — `setuptools_scm`; no hardcoded version in `pyproject.toml`
- **Core runtime deps** — [list project-specific deps here, e.g. fastmcp, anthropic, qdrant-client]
  plus the standard template deps (pydantic, pydantic-settings, loguru, click)

### Make targets — always prefer these over raw commands

| Target | What it does |
|---|---|
| `make dev` | `uv python pin` + `uv sync --group dev` |
| `make install` | `uv sync --no-dev` |
| `make test` | `pytest tests/unit/` — fast, no external deps; run before every commit |
| `make integration-tests` | `pytest tests/integration/ --slow` — may require API keys |
| `make workflow-tests` | `pytest tests/workflows/ --workflow` — named end-to-end flows |
| `make all-tests` | unit + integration + workflow — CI gate |
| `make lint` | `ruff check` + `ruff format --check` + `mypy` |
| `make fix-ruff` | `ruff check --fix` + `ruff format` (auto-fix) |
| `make check-ruff` | ruff check + format in check-only mode (no fix) |
| `make check-ruff-diff` | show ruff diff without applying changes |
| `make mypy` | mypy on package folders only |
| `make verify-lock` | check lockfile is consistent with `pyproject.toml` |

Do not edit the Makefile. If a make target appears wrong, flag it — do not
work around it inline.

### Managing dependencies

The `pyproject.toml` template includes a standard set of dependencies. Project-specific
deps are added to `[project] dependencies` (runtime) or `[dependency-groups] dev` (dev/test).

If a new dependency is needed during implementation:
1. Add it to the appropriate section in `pyproject.toml`
2. Run `make dev` to resolve and sync
3. Commit `pyproject.toml` and `uv.lock` together, before the implementation commit

Never import a library not listed in `pyproject.toml`. Never assume a package is
available because it is commonly used — check first.

---

## Package Layout

All paths are relative to the project root (where `pyproject.toml` lives).

```
my_prj/                       # project root
├── CLAUDE.md
├── Makefile                  # do not edit
├── pyproject.toml
├── .env.example
├── my_prj/                   # main importable package
│   ├── __init__.py
│   ├── py.typed
│   └── cli.py
├── my_prj_config/            # configuration and settings
│   ├── __init__.py
│   ├── py.typed
│   └── config.py
├── tests/
│   ├── conftest.py           # declares pytest_plugins only
│   ├── data/                 # shared read-only test data (pytest-datadir)
│   ├── fixtures/             # one module per fixture domain
│   │   ├── __init__.py
│   │   └── test_fixtures.py
│   ├── unit/
│   ├── integration/
│   └── workflows/
└── docs/
    └── project/              # reference docs — read before each work unit
```

Extend this tree with project-specific directories before your first session.
Do not create additional top-level modules without updating this file.

---

## Module Ownership Rules

[Replace with project-specific rules before your first session.]

| File / directory | Owns |
|---|---|
| `my_prj_config/config.py` | All settings and environment variable definitions |
| `my_prj/` | Core application logic |

---

## Non-Negotiable Invariants

[Replace with project-specific design contracts that must never be violated
regardless of local convenience. Delete this instruction when done.]

---

## Git Workflow

One issue → one branch → one pull request → main.

**Branch naming:** `feat/<issue-id>-<short-slug>`
- e.g. `feat/wp1-t2-entity-factory-registry`

**Commit message format:** `<issue-id>: <imperative summary>`
- e.g. `WP1-T2: implement entity factories with UUID assignment`

**Before writing any code:** run `git branch --show-current` and confirm the
branch matches the issue being worked on. Never commit directly to `main`.

**When adding a dependency mid-issue:** commit `pyproject.toml` + `uv.lock`
together in a dedicated commit before the implementation commit.

---

## Testing Conventions

Full conventions and fixture signatures are in `docs/project/testing_philosophy.md`.
The rules below apply everywhere without exception.

- **Style** — flat `pytest` functions throughout. No test classes unless a class
  is genuinely necessary to share expensive setup that cannot be a fixture.
- **Async** — `asyncio_mode = "auto"` is set in `pyproject.toml`. Do not add
  `@pytest.mark.asyncio` decorators.
- **Fixtures** — defined in `tests/fixtures/` modules, one module per domain.
  `tests/conftest.py` declares them via `pytest_plugins` and nothing else.
- **Test data** — use `pytest-datadir`'s `shared_datadir` fixture for read-only
  reference files in `tests/data/`. Use `datadir` only when a test must mutate files.
- **Coverage gate** — 80% minimum enforced in CI. Unit tests alone must clear
  this threshold.
  - Add genuinely untestable files (CLI entry points, stub files) to
    `[tool.coverage.run] omit` in `pyproject.toml` with an explanatory comment.
  - Do not lower `fail_under` without flagging it for human approval.
- **Slow marker** — integration tests use `@pytest.mark.slow`. They run with
  `make integration-tests` or `make all-tests`, not with `make test`.
- **Workflow tests** — use `pytest-workflow` for end-to-end flows that invoke
  CLI commands and assert on output files or exit codes. Lives in `tests/workflows/`.
- **Naming** — `test_<component>_<behaviour>_<condition>`

---

## Current Work Status

[Replace the table below with your project's work packages, milestones, or
sprint items. Update the Status column manually as work progresses.]

| Unit | Focus | Status |
|---|---|---|
| WP1 | [description] | not started |
| WP2 | [description] | not started |

---

## Reference Docs — Read Before Starting Each Work Unit

**Always read first (every session):**
- `docs/project/architecture.md` — system overview and component relationships
- `docs/project/design_decisions.md` — rationale for key design choices

**Before writing any tests:**
- `docs/project/testing_philosophy.md` — full conventions, fixture signatures,
  coverage targets, workflow test structure

**Work-unit specs — read when starting that unit:**
- `docs/project/wp1_spec.md` — [brief description]
- `docs/project/wp2_spec.md` — [brief description]

[Add or remove spec pointers to match your actual work breakdown.]
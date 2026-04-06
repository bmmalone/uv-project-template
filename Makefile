SHELL := /bin/bash
python_version     := 3.12.10
list_ignored_files := git ls-files --others --ignored --exclude-standard --directory
do_not_clean       := -e "\.env*" -e "scratch.*ipynb" -e ".vscode" -e ".*local\.csv" -e ".*json"
python_folders     := my_prj_config my_prj

## ─── help ────────────────────────────────────────────────────────────────────

.PHONY: help
help:
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Environment"
	@echo "  dev              Pin Python, install all deps including dev group"
	@echo "  install          Install runtime deps only (no dev group)"
	@echo "  lock             Regenerate uv.lock"
	@echo "  verify-lock      Check lockfile is consistent with pyproject.toml"
	@echo ""
	@echo "Testing"
	@echo "  test             Unit tests only — fast, no external deps (default)"
	@echo "  integration-tests  Integration tests (--slow, requires API key)"
	@echo "  workflow-tests   Named end-to-end workflow tests (pytest-workflow)"
	@echo "  all-tests        Full suite: unit + integration + workflow"
	@echo ""
	@echo "Linting"
	@echo "  lint             ruff check + ruff format --check + mypy"
	@echo "  check-ruff       ruff check + format in check-only mode"
	@echo "  check-ruff-diff  Show ruff diff without applying changes"
	@echo "  fix-ruff         Auto-fix ruff issues and format"
	@echo "  mypy             Run mypy on package folders"
	@echo ""
	@echo "Maintenance"
	@echo "  clean            Remove all .gitignore-d files (except .env, scratch notebooks)"
	@echo "  check-clean      Preview what clean would remove"
	@echo "  wheel            Build a distributable wheel"
	@echo ""

## ─── environment ─────────────────────────────────────────────────────────────

.PHONY: dev
dev:
	uv python pin $(python_version)
	uv sync --group dev

.PHONY: install
install:
	uv sync --no-dev

.PHONY: lock
lock:
	uv lock

.PHONY: verify-lock
verify-lock:
	uv lock --check

## ─── testing ─────────────────────────────────────────────────────────────────

.PHONY: test
test:
	uv run pytest tests/unit/

.PHONY: integration-tests
integration-tests:
	uv run pytest tests/integration/ --slow

.PHONY: workflow-tests
workflow-tests:
	uv run pytest tests/workflows/ --workflow

.PHONY: all-tests
all-tests: test integration-tests workflow-tests

## ─── linting ─────────────────────────────────────────────────────────────────

.PHONY: lint
lint: check-ruff mypy

.PHONY: check-ruff
check-ruff:
	uv run ruff check $(python_folders) tests/
	uv run ruff format --check $(python_folders) tests/

.PHONY: check-ruff-diff
check-ruff-diff:
	uv run ruff check --diff $(python_folders) tests/
	uv run ruff format --diff $(python_folders) tests/

.PHONY: fix-ruff
fix-ruff:
	uv run ruff check --fix $(python_folders) tests/
	uv run ruff format $(python_folders) tests/

.PHONY: mypy
mypy:
	uv run mypy $(python_folders)

## ─── maintenance ─────────────────────────────────────────────────────────────

.PHONY: clean
clean:
	@echo "Cleaning:"
	@$(list_ignored_files) | grep -v $(do_not_clean)
	$(list_ignored_files)  | grep -v $(do_not_clean) | xargs -I{} rm -rf {}

.PHONY: check-clean
check-clean:
	@echo "Would clean the following files:"
	@$(list_ignored_files) | grep -v $(do_not_clean)

.PHONY: wheel
wheel: clean
	uv build
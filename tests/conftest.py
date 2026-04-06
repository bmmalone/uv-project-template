import pytest
from loguru import logger

from .fixtures.test_fixtures import mock_fixture

# It's good practice to disable loguru's default handlers during tests to avoid noise.
logger.remove()
# Direct output to stdout (and also allow for caplog)
logger.add(lambda msg: print(msg), level="INFO", serialize=False)

###
# To add a new fixture module:
# 1. Create tests/fixtures/your_domain_fixtures.py
# 2. Add "tests.fixtures.your_domain_fixtures" to the list below
###
pytest_plugins = [
    "tests.fixtures.test_fixtures",
]


###
# Skip slow tests by default
###
def pytest_addoption(parser):
    parser.addini("slow", "whether to run slow tests or not", default="false")
    parser.addoption("--slow", action="store_true", help="run slow tests")

    parser.addini("external", "whether to run tests which use external APIs", default="false")
    parser.addoption("--external", action="store_true", help="run external API tests")


def pytest_runtest_setup(item):
    if "slow" in item.keywords and item.config.getini("slow") == "false" and not item.config.getoption("--slow"):
        pytest.skip("Skipping slow test by default. Use --slow to run.")

    if (
        "external" in item.keywords
        and item.config.getini("external") == "false"
        and not item.config.getoption("--external")
    ):
        pytest.skip("Skipping tests with external API calls by default. Use --external to run.")

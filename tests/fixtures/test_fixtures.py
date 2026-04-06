from pathlib import Path
from unittest.mock import Mock

import pytest


@pytest.fixture
def mock_fixture() -> Mock:
    """Mocks a test object"""
    return Mock()


@pytest.fixture
def dummy_data_path(shared_datadir: Path) -> Path:
    """Path to the shared dummy CSV in tests/data/."""
    return shared_datadir / "dummy-data.csv"
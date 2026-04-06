"""Pydantic models for various configuration settings, such as API keys"""

import pathlib

from pydantic import SecretStr
from pydantic_settings import BaseSettings, SettingsConfigDict


class PineconeSettings(BaseSettings):
    dimension: int = 768
    metric: str = "cosine"
    cloud: str = "aws"
    region: str = "us-east-1"


class CloudAPISettings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=(pathlib.Path(__file__).parent.parent / ".env", "")
    )
    google_api_key: SecretStr
    llama_cloud_api_key: SecretStr
    pinecone_api_key: SecretStr
    pinecone_index_name: str

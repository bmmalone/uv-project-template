from .config import CloudAPISettings, PineconeSettings

cloud_api_settings = CloudAPISettings()  # type: ignore

__all__ = ["PineconeSettings", "cloud_api_settings"]

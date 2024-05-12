import yaml
from pydantic_settings import BaseSettings
from importlib import resources


# Define your settings model
class AppConfig(BaseSettings):
    host: str = "localhost"  # Default values can be specified
    port: int = 5000
    debug: bool = False

    class Config:
        env_prefix = "EYRIE_"  # Prefix for environment variables
        extra = "ignore"  # Ignore fields not defined in the model


# Function to load settings from a YAML file
def load_settings():
    with resources.open_text("eyrie.settings", "defaults.yaml") as f:
        # Load the YAML configuration
        data = yaml.safe_load(f)
        # Create and return an AppConfig instance
        return AppConfig(**data)


# Example usage
settings = load_settings()
print(settings.json())  # Print settings as a JSON string for demonstration

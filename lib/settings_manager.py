import os
from pathlib import Path
from typing import Any, Dict

import tomlkit  # Supports comments

# Path to the TOML configuration file
CONFIG_FILE = Path("config.toml")


class SettingsManager:
    """Class to manage application settings stored in a TOML file and loaded into environment variables."""

    def __init__(self, config_path: Path = CONFIG_FILE):
        self.config_path = config_path
        if not self.config_path.exists():
            raise FileNotFoundError(f"Configuration file not found at {self.config_path}")

    def load_settings_to_env(self) -> None:
        """
        Load settings from the TOML file into environment variables.
        """
        settings = self._read_config()
        for section, values in settings.items():
            if isinstance(values, dict):  # Nested dictionary for sections
                for key, value in values.items():
                    if value is not None:
                        os.environ[key.upper()] = str(value)  # Store as uppercase in env
            else:
                os.environ[section.upper()] = str(values)

    def get_settings(self) -> Dict[str, Any]:
        """
        Retrieve the settings from the TOML file as a dictionary.
        """
        return self._read_config()

    def update_setting(self, section: str, key: str, value: Any) -> None:
        """
        Update a specific setting in the TOML file and the environment.
        """
        settings = self._read_config()
        if section not in settings:
            settings[section] = {}

        settings[section][key] = value

        # Write back to the TOML file
        self._write_config(settings)

        # Update the environment variable
        os.environ[key.upper()] = str(value)

    def _read_config(self) -> Dict[str, Any]:
        """
        Internal method to read the TOML configuration file using tomlkit (preserves comments).
        """
        with open(self.config_path, "r") as file:
            return tomlkit.loads(file.read())

    def _write_config(self, settings: Dict[str, Any]) -> None:
        """
        Internal method to write the updated settings back to the TOML file using tomlkit (preserves comments).
        """
        with open(self.config_path, "w") as file:
            file.write(tomlkit.dumps(settings))

import os
import sys
from pathlib import Path

from watchfiles import run_process

from lib.settings_manager import SettingsManager

# Add the project root directory to PYTHONPATH
project_root = Path(__file__).resolve().parent.parent  # Adjust to point to project root
sys.path.append(str(project_root))  # Add project root

def run_gradio():
    import gradio as gr

    from web.settings import settings_ui  # Import the settings UI
    SERVER_PORT = int(os.getenv("SERVER_PORT", 5555))

    # Main Gradio UI
    def greet(name: str) -> str:
        return f"Hello, {name}!"

    with gr.Blocks() as app:
        gr.Markdown("# Model Management Tool")

        with gr.Row():
            gr.Button("Model Sharing", elem_id="model-sharing-btn")
            gr.Button("Settings", elem_id="settings-btn")

        # Add Settings UI dynamically
        settings_ui(app)

        gr.Markdown("## Jello World!")  # Keep the placeholder hello world

        app.launch(server_port=SERVER_PORT, server_name="0.0.0.0")

def setup_environment():
    """Load settings into the environment at application startup."""
    settings_manager = SettingsManager()
    settings_manager.load_settings_to_env()

if __name__ == "__main__":
    setup_environment()
    # Watch the directory for changes and reload automatically
    run_process(".", target=run_gradio)

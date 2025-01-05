import os

import gradio as gr
from watchfiles import run_process

from lib.settings_manager import SettingsManager
from web.settings import settings_ui


def setup_environment():
    """Load settings into the environment at application startup."""
    settings_manager = SettingsManager()
    settings_manager.load_settings_to_env()


def create_app():
    """Create and configure the Gradio application."""
    with gr.Blocks(theme=gr.themes.Soft()) as app:
        gr.Markdown("# Model Management Tool")
        
        # Main content area using Tabs for better organization
        with gr.Tabs():
            with gr.Tab("Home", id="home"):
                gr.Markdown(
                    "Welcome to the Model Management Tool!",
                    elem_id="main-content"
                )
            
            with gr.Tab("Settings", id="settings"):
                settings_ui()

    return app


def run_gradio():
    """Launch the Gradio application with specified configuration."""
    SERVER_PORT = int(os.getenv("SERVER_PORT", 5555))
    app = create_app()
    app.launch(
        server_port=SERVER_PORT,
        server_name="0.0.0.0",
        show_error=True,
        share=False
    )


if __name__ == "__main__":
    setup_environment()
    run_process(".", target=run_gradio)

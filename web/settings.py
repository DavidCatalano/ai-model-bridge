import gradio as gr

from lib.settings_manager import SettingsManager


def settings_ui(app):
    """
    Dynamically generate the settings UI based on the TOML file contents.
    """
    settings_manager = SettingsManager()
    settings = settings_manager.get_settings()

    with app:
        gr.Markdown("## Application Settings")
        with gr.Row():
            for section, section_values in settings.items():
                gr.Markdown(f"### {section.capitalize()}")
                for key, value in section_values.items():
                    textbox = gr.Textbox(
                        label=f"{key.replace('_', ' ').capitalize()}",
                        value=value,
                        interactive=True,
                    )
                    # Save updates back to the TOML file and env
                    textbox.change(
                        lambda new_value, section=section, key=key: settings_manager.update_setting(
                            section, key, new_value
                        ),
                        inputs=[textbox],
                    )

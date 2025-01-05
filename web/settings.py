from typing import Any

import gradio as gr

from lib.settings_manager import SettingsManager


def create_setting_component(
    value: Any,
    label: str
) -> gr.components.Component:
    """
    Create appropriate Gradio component based on setting value type.
    """
    if isinstance(value, bool):
        return gr.Checkbox(value=value, label=label)
    elif isinstance(value, int):
        return gr.Number(value=value, label=label, precision=0)
    elif isinstance(value, float):
        return gr.Number(value=value, label=label)
    else:
        return gr.Textbox(value=str(value), label=label)

def settings_ui() -> gr.Blocks:
    """
    Generate a dynamic settings UI with appropriate input components
    and real-time validation.
    """
    settings_manager = SettingsManager()
    settings = settings_manager.get_settings()

    def update_setting(new_value: Any, section: str, key: str) -> dict[str, Any]:
        """Update setting and provide feedback."""
        try:
            settings_manager.update_setting(section, key, new_value)
            return gr.update(
                value=f"✓ Updated {key} successfully",
                visible=True
            )
        except Exception as e:
            return gr.update(
                value=f"⚠️ Error updating {key}: {str(e)}",
                visible=True
            )

    with gr.Blocks() as settings_block:
        gr.Markdown("## Application Settings")
        
        # Create tabs for each settings section
        with gr.Tabs() as section_tabs:
            for section, section_values in settings.items():
                with gr.Tab(section.capitalize()):
                    with gr.Group():
                        for key, value in section_values.items():
                            with gr.Row():
                                # Create appropriate input component
                                input_component = create_setting_component(
                                    value=value,
                                    label=key.replace('_', ' ').capitalize()
                                )
                                
                                # Hidden state components
                                section_state = gr.State(value=section)
                                key_state = gr.State(value=key)
                                
                                # Status message
                                status = gr.Textbox(
                                    label="Status",
                                    visible=False,
                                    interactive=False
                                )
                            
                            # Register change event
                            input_component.change(
                                fn=update_setting,
                                inputs=[
                                    input_component,
                                    section_state,
                                    key_state
                                ],
                                outputs=status
                            )
                            
                            # Add spacing between settings
                            gr.Markdown("---")

    return settings_block
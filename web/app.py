import os

from watchfiles import run_process


def run_gradio():
    import gradio as gr
    SERVER_PORT = int(os.getenv("SERVER_PORT", 5555))

    def greet(name: str) -> str:
        return f"Hello, {name}!"

    with gr.Interface(fn=greet, inputs="text", outputs="text", title="Hello World") as demo:
        demo.launch(server_port=SERVER_PORT, server_name="0.0.0.0")

if __name__ == "__main__":
    run_process(".", target=run_gradio)

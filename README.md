# ai-model-bridge

**ModelBridge** streamlines the file management of large language models and image generation models through efficient organization and symbolic linking. This containerized solution prevents redundant downloads across different frameworks and applications while optimizing model loading performance through intelligent storage management across mixed drive environments (mechanical and NVMe). ModelBridge simplifies the workflow for text generation and generative applications, providing a unified command-line interface for model organization and optimization. (or aspires to ;)

## Goals
- **Reuse model files across frameworks such as Ollama, LlamaCPP, and others.**
- Centralize model storage with symlinking for framework-specific requirements.
- Provide intuitive shell scripts with GUIs when neccessary for data presentation and manipulation.
- Optimize performance for frequently used models by utilizing NVMe storage.
- Offer terminal-based CLI for model management.
- Enable seamless integration with tools via a Gradio front-end in future iterations.
- **Provide a toolbox of commonly used cli tools in an easily maintainable container.**

## Features
- **Unified Storage**: Consolidates model files, creating symlinks for individual frameworks.
- **CLI Tools**: Incorporates essential tools such as Ollama CLI, LlamaCPP, and Hugging Face Hub CLI for managing and converting models.
- **Extensible Architecture**: Designed for future enhancements, such as Gradio front-end integration and expandable set of compatible applications.

## Installation

### Prerequisites
- Docker and Docker Compose
- ??? NVidia GPU
    - Is this really needed ever/yet? If so then Nvidia Container Toolkit on host machine and more complicated setup if so...
    - Contribution welcome for: CPU, AMD and Apple Silicon support

### Setup
1. Clone the repository:
   ```
   git clone https://github.com/davidcatalano/ai-model-bridge.git
   ```
2. Modify config.toml with the file paths and other settings
3. Copy and edit .env.example
    ```
    cp .env.example .env
    ```
    #### File Permissions and GID Setup
      To ensure compatibility when sharing files between containers:

      1. **Use a Common GID**:
         - Set `APP_RUNTIME_GID` to the group ID (`GID`) used by other containers sharing files.
         - Example: If the other containers use GID `24060`, set:
         ```plaintext
         APP_RUNTIME_GID=24060
         ```
         - This promotes security best practices, ensures consistent access and avoids permission issues.

      2. **Fallback to Root**:
         - If other containers are running as `root` or no common GID is used, leave `APP_RUNTIME_GID` blank.
         - ModelBridge will also run as `root`, ensuring it can access files created by `root` containers.

4. Adjust the docker-compose.yml file as needed

5. Build or rebuild the Docker container:
   ```
   docker-compose --build
   ```
6. Start or stop the container
    ```
    docker-compose up
    ```
    For now, this will land you in the interactive terminal

## Utilities Included
- **[Ollama CLI](https://ollama.ai/)**: Manage Ollama-specific models.
- **[Hugging Face Hub CLI](https://huggingface.co/docs/hub/)**: Download and manage Hugging Face models and datasets.
- **[LlamaCPP](https://github.com/ggerganov/llama.cpp)**: Quantize and convert GGUF model files.


## Existing and Sample Workflows
1. **Ollama Model linking to Koboldcpp**:
   ```
   ./scripts/kollama.sh
   ```
2. **Ollama Model linking to oobabooga/text-generation-webui**:
   ```
   ./scripts/ollooba.sh
   ```
3. **Civit.ai Model Downloader**:
   ```
   ./scripts/dlcivitai.sh
   ```
   Resume downloads that timeout via various webui managers

## Future Goals
- Leverage faster NVMe drives for improved model loading performance.
- Develop a Gradio-based front-end to complement the CLI.
- Expand framework compatibility with additional CLI tools.
- Integrate APIs for seamless application extension (like oobagooga extension).

## Technical details

### Application flow
Container (base)
→ Dockerfile (future: optional)
  → start_linux.sh / sets up miniconda/env (future: multi OS support)
    → start.py / python setup (requirements.txt) and routes based on args
Container (remote dev)
      ↑ all of the above, plus...
      → devcontainer.json / adds requirements-dev.txt

## Contributions
My primary contribution and motivation for this project focuses on Linux and remote Docker container setups. Contributions are welcome to expand and refine the project for additional use cases, including:

- Localhost environments on Windows, macOS, and Linux.
- Enhancements for standalone installations without Docker.
- Compatibility improvements for different hardware setups (e.g., CPU-only machines, Apple Silicon, AMD/Intel GPUs).

If you have ideas or improvements, please open an issue or submit a pull request to discuss them!


## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

#!/usr/bin/env bash

case "$1" in
    "exllamav2-prep")
        if [[ "$CONDA_DEFAULT_ENV" != "/opt/ai-model-bridge/miniconda/env" ]]; then
            echo "Error: Please activate the conda environment first:"
            echo "source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate /opt/ai-model-bridge/miniconda/env"
            exit 1
        fi
        
        echo "Installing GCC requirements for ExLlamaV2..."
        if conda install -y -c conda-forge gcc gxx; then
            echo "GCC requirements for ExLlamaV2 installed successfully"
        else
            echo "Failed to install GCC requirements"
            exit 1
        fi
        ;;
    "conda")
        source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate /opt/ai-model-bridge/miniconda/env
        ;;
    "bashrc")
        echo "Appending Conda environment activation to ~/.bashrc"
        echo "source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate /opt/ai-model-bridge/miniconda/env" >> ~/.bashrc
        echo "Done. The environment will activate automatically when you start a new shell."
        ;;
    "setup-bash")
        docker exec -it modelbridge bash -c "
            export PATH=\"\$PATH:\$HOME/.local/bin\" && \
            if ! grep -Fxq 'source /opt/ai-model-bridge/miniconda/conda/bin/activate' ~/.bashrc; then
                echo 'source /opt/ai-model-bridge/miniconda/conda/bin/activate' >> ~/.bashrc;
            fi
            if ! grep -Fxq 'conda activate /opt/ai-model-bridge/miniconda/env' ~/.bashrc; then
                echo 'conda activate /opt/ai-model-bridge/miniconda/env' >> ~/.bashrc;
            fi
        " || {
            echo 'Failed to set up the development environment.'
            exit 1
        }
        ;;
    *)
        echo "Usage: $0 {conda|exllamav2-prep|bashrc|setup-pip|setup-bash}"
        exit 1
        ;;
esac

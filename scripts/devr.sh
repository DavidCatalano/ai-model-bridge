#!/usr/bin/env bash

case "$1" in
    "conda")
        source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate /opt/ai-model-bridge/miniconda/env
        ;;
    "bashrc")
        echo "Appending Conda environment activation to ~/.bashrc"
        echo "source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate /opt/ai-model-bridge/miniconda/env" >> ~/.bashrc
        echo "Done. The environment will activate automatically when you start a new shell."
        ;;
    "setup-pip")
        docker exec -it modelbridge bash -c "
            export PATH=\"\$PATH:\$HOME/.local/bin\" && \
            python -m pip install --upgrade pip && \
            pip install -r requirements-dev.txt && \
            ruff check . --fix
        " || {
            echo 'Failed to set up the development environment.'
            exit 1
        }
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
        echo "Usage: $0 {bashrc|setup-pip|setup-bash}"
        exit 1
        ;;
esac

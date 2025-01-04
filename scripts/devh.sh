#!/bin/bash

case "$1" in
    "build-repo")
        docker-compose build --build-arg CACHEBUST=$(date +%s)
        ;;
    "build-no-cache")
        docker-compose build --no-cache
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
    "bash")
        docker exec -it modelbridge bash
        ;;
    *)
        echo "Usage: $0 {build-repo|build-no-cache|setup-pip|setup-bash|bash}"
        exit 1
        ;;
esac

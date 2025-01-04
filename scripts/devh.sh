#!/bin/bash

case "$1" in
    "build-repo")
        docker-compose build --build-arg CACHEBUST=$(date +%s)
        ;;
    "build-no-cache")
        docker-compose build --no-cache
        ;;
    "setup")
    docker exec -it modelbridge bash -c "
        export PATH=\"\$PATH:\$HOME/.local/bin\" && \
        python -m pip install --upgrade pip && \
        pip install -r requirements-dev.txt && \
        ruff check . --fix && \
        if ! grep -Fxq 'export PATH=\"\$PATH:/home/app/ai-model-bridge/scripts\"' ~/.bashrc; then
            echo 'export PATH=\"\$PATH:/home/app/ai-model-bridge/scripts\"' >> ~/.bashrc;
        fi
    " || {
        echo 'Failed to set up the development environment.'
        exit 1
    }
    ;;
    "bash")
        docker exec -it modelbridge bash -c "source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate /opt/ai-model-bridge/miniconda/env && bash"
        ;;
    *)
        echo "Usage: $0 {build-repo|build-no-cache|setup|bash}"
        exit 1
        ;;
esac

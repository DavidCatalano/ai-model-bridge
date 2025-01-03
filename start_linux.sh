#!/usr/bin/env bash

# Navigate to script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Check for unsupported configurations
OS=$(uname)
if [[ "$OS" != "Linux" ]]; then
    echo "Unsupported OS: $OS. This script currently supports Linux only." && exit 1
fi

OS_ARCH=$(uname -m)
case "${OS_ARCH}" in
    x86_64*)    OS_ARCH="x86_64";;
    arm64* | aarch64*) OS_ARCH="aarch64";;
    *)          echo "Unsupported architecture: $OS_ARCH. Only x86_64 and arm64 are supported." && exit 1
esac

# Define paths and URLs
INSTALL_DIR="/opt/ai-model-bridge/miniconda"
CONDA_ROOT_PREFIX="$INSTALL_DIR/conda"
INSTALL_ENV_DIR="$INSTALL_DIR/env"
MINICONDA_DOWNLOAD_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-${OS_ARCH}.sh"

# Check for existing conda installation
if ! "$CONDA_ROOT_PREFIX/bin/conda" --version &>/dev/null; then
    echo "Installing Miniconda..."
    mkdir -p "$INSTALL_DIR"
    curl -L "$MINICONDA_DOWNLOAD_URL" > "$INSTALL_DIR/miniconda_installer.sh"
    bash "$INSTALL_DIR/miniconda_installer.sh" -b -p "$CONDA_ROOT_PREFIX"
    rm "$INSTALL_DIR/miniconda_installer.sh"
fi

# Create the environment if needed
if [ ! -e "$INSTALL_ENV_DIR" ]; then
    "$CONDA_ROOT_PREFIX/bin/conda" create -y -k --prefix "$INSTALL_ENV_DIR" python=3.11
fi

# Verify environment
if [ ! -e "$INSTALL_ENV_DIR/bin/python" ]; then
    echo "Failed to create Conda environment." && exit 1
fi

# Activate environment and run installer
source "$CONDA_ROOT_PREFIX/etc/profile.d/conda.sh"
conda activate "$INSTALL_ENV_DIR"

python start.py "$@"

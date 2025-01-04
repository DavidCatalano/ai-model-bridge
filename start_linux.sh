#!/usr/bin/env bash
if [[ " $@ " =~ " --verbose " ]]; then
    echo "Arguments passed to start_linux.sh: $@"
    echo "Current umask in entrypoint: $(umask)"
fi
    

# Navigate to script directory
cd "$(dirname "${BASH_SOURCE[0]}")"

# Check for unsupported configurations
OS=$(uname)
if [[ "$OS" != "Linux" ]]; then
    echo "Unsupported OS: $OS. This script currently supports Linux only." && return 1
fi

# Determine system architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64 | amd64) ARCH="x86_64" ;;
    arm64 | aarch64) ARCH="aarch64" ;;
    *) echo "Unsupported architecture: $ARCH. Only x86_64 and arm64 are supported." && return 1 ;;
esac

# Define paths and URLs
INSTALL_DIR="/opt/ai-model-bridge/miniconda"
CONDA_ROOT_PREFIX="$INSTALL_DIR/conda"
INSTALL_ENV_DIR="$INSTALL_DIR/env"
MINICONDA_DOWNLOAD_URL="https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-${ARCH}.sh"

# Trap to clean up installer file in case of exit
trap 'rm -f "$INSTALL_DIR/miniconda_installer.sh"' EXIT

# Check for existing conda installation
if ! "$CONDA_ROOT_PREFIX/bin/conda" --version &>/dev/null; then
    echo "Installing Miniconda..."
    mkdir -p "$INSTALL_DIR"
    if ! curl -L "$MINICONDA_DOWNLOAD_URL" -o "$INSTALL_DIR/miniconda_installer.sh"; then
        echo "Failed to download Miniconda installer from $MINICONDA_DOWNLOAD_URL" && return 1
    fi
    if ! bash "$INSTALL_DIR/miniconda_installer.sh" -b -p "$CONDA_ROOT_PREFIX"; then
        echo "Failed to install Miniconda." && return 1
    fi
fi

# Create the environment if needed
if [ ! -e "$INSTALL_ENV_DIR" ]; then
    if ! "$CONDA_ROOT_PREFIX/bin/conda" create -y -k --prefix "$INSTALL_ENV_DIR" python=3.11; then
        echo "Failed to create Conda environment." && return 1
    fi
fi

# Verify environment
if [ ! -e "$INSTALL_ENV_DIR/bin/python" ]; then
    echo "Failed to create Conda environment." && return 1
fi

# Activate environment and run installer
source "$CONDA_ROOT_PREFIX/etc/profile.d/conda.sh"
conda activate "$INSTALL_ENV_DIR"

python start.py "$@"

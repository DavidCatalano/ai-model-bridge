import os
import subprocess
import sys

# Constants
REPO_URL = "https://github.com/turboderp-org/exllamav2.git"
DEST_DIR = os.path.join(os.path.dirname(__file__), "extensions", "exllamav2")
SPARSE_DIRS = [
    "convert.py",
    "exllamav2/conversion/",
    "exllamav2/exllamav2_ext/",
    "util/convert_safetensors.py",
    "util/shard.py",
    "util/unshard.py",
]
CONDA_ENV = "/opt/ai-model-bridge/miniconda/env"


def check_nvidia():
    """Verify NVIDIA setup and GPU availability."""
    print("Verifying NVIDIA environment and setup...")
    try:
        subprocess.run(["nvidia-smi"], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except FileNotFoundError:
        print("Error: nvidia-smi not found. Ensure NVIDIA drivers are installed and accessible.")
        sys.exit(1)

    # Check if GPUs are visible
    try:
        result = subprocess.run(["nvidia-smi", "-L"], check=True, stdout=subprocess.PIPE, text=True)
        if not result.stdout.strip():
            print("Error: No GPUs detected or driver issues present.")
            sys.exit(1)
        print(f"NVIDIA GPUs detected:\n{result.stdout}")
    except subprocess.CalledProcessError:
        print("Error: Failed to detect NVIDIA GPUs.")
        sys.exit(1)


def check_conda_env():
    """Verify if the correct Conda environment is active."""
    conda_env = os.environ.get("CONDA_DEFAULT_ENV", "")
    if conda_env != CONDA_ENV:
        print(f"Error: Please activate the Conda environment first:\n"
              f"source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate {CONDA_ENV}")
        sys.exit(1)
    print(f"Conda environment verified: {conda_env}")


def install_gcc():
    """Install GCC using Conda."""
    print("Installing GCC requirements for ExLlamaV2...")
    try:
        subprocess.run(["conda", "install", "-y", "-c", "conda-forge", "gcc", "gxx"], check=True)
        print("GCC requirements installed successfully.")
    except subprocess.CalledProcessError:
        print("Error: Failed to install GCC requirements.")
        sys.exit(1)


def clone_repo():
    """Clone the repository into the destination directory."""
    if not os.path.exists(DEST_DIR):
        print(f"Cloning repository into {DEST_DIR}...")
        subprocess.run(["git", "clone", "--no-checkout", REPO_URL, DEST_DIR], check=True)
    else:
        print(f"Repository already exists in {DEST_DIR}. Skipping clone.")


def sparse_checkout():
    """Perform Git sparse-checkout for the required files."""
    os.chdir(DEST_DIR)
    print("Initializing sparse-checkout...")
    subprocess.run(["git", "sparse-checkout", "init", "--cone"], check=True)
    subprocess.run(["git", "sparse-checkout", "set"] + SPARSE_DIRS, check=True)
    print("Pulling sparse-checkout files...")
    subprocess.run(["git", "checkout"], check=True)


def install_dependencies():
    """Install Python dependencies."""
    print("Installing ExLlamaV2 via pip...")
    subprocess.run(["pip", "install", "-e", DEST_DIR], check=True)

    req_file = os.path.join(DEST_DIR, "requirements.txt")
    if os.path.exists(req_file):
        print("Installing additional dependencies from requirements.txt...")
        subprocess.run(["pip", "install", "-r", req_file], check=True)
    else:
        print("No requirements.txt found in the ExLlamaV2 repository. Skipping additional dependency installation.")


def jit_compile():
    """Trigger JIT compilation for ExLlamaV2."""
    print("Running JIT compilation check for ExLlamaV2...")
    try:
        subprocess.run(["python", "-c", "from exllamav2 import ExLlamaV2; print('ExLlamaV2 JIT setup successful.')"], check=True)
    except subprocess.CalledProcessError:
        print("Error: JIT compilation for ExLlamaV2 failed.")
        sys.exit(1)


def main():
    print("Setting up ExLlamaV2 extension...")
    check_nvidia()
    check_conda_env()
    install_gcc()
    clone_repo()
    sparse_checkout()
    install_dependencies()
    jit_compile()
    print("ExLlamaV2 setup complete!")


if __name__ == "__main__":
    main()

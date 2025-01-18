import os
import subprocess
import sys

# Constants
REPO_URL = "https://github.com/turboderp-org/exllamav2.git"
DEST_DIR = os.path.join(os.path.dirname(__file__), "exllamav2_utils_repo")
SPARSE_DIRS = [
    "convert.py",
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
        print("Error: nvidia-smi not found. Ensure NVIDIA drivers are installed.")
        sys.exit(1)

    # Check if GPUs are visible
    try:
        result = subprocess.run(["nvidia-smi", "-L"], check=True, stdout=subprocess.PIPE, text=True)
        if not result.stdout.strip():
            print("Error: No GPUs detected.")
            sys.exit(1)
        print(f"NVIDIA GPUs detected:\n{result.stdout}")
    except subprocess.CalledProcessError:
        print("Error: Failed to detect NVIDIA GPUs.")
        sys.exit(1)

def check_conda_env():
    """Verify if the correct Conda environment is active."""
    conda_env = os.environ.get("CONDA_DEFAULT_ENV", "")
    if conda_env != CONDA_ENV:
        print(f"Error: Please activate Conda environment:\n"
              f"source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate {CONDA_ENV}")
        sys.exit(1)
    print(f"Conda environment verified: {conda_env}")

def install_pypi_package():
    """Install the PyPI version of ExLlamaV2."""
    print("Installing ExLlamaV2 from PyPI...")
    try:
        subprocess.run(["pip", "install", "exllamav2"], check=True)
        print("ExLlamaV2 installed successfully.")
    except subprocess.CalledProcessError:
        print("Error: Failed to install ExLlamaV2 from PyPI.")
        sys.exit(1)

def jit_compile():
    """Activate the JIT compiler to verify ExLlamaV2 functionality."""
    print("Running JIT compilation for ExLlamaV2...")
    try:
        subprocess.run(["python", "-c", "from exllamav2 import ExLlamaV2; print('JIT setup successful.')"], check=True)
    except subprocess.CalledProcessError:
        print("Error: JIT compilation for ExLlamaV2 failed.")
        sys.exit(1)

def clone_repo():
    """Clone the repository for sparse-checkout."""
    os.makedirs(os.path.dirname(DEST_DIR), exist_ok=True)
    if not os.path.exists(DEST_DIR):
        print(f"Cloning repository into {DEST_DIR}...")
        subprocess.run(["git", "clone", "--no-checkout", REPO_URL, DEST_DIR], check=True)
    else:
        print("Repository already exists. Skipping clone.")

def sparse_checkout():
    """Sparse-checkout only utility files."""
    os.chdir(DEST_DIR)
    print("Initializing sparse-checkout...")
    subprocess.run(["git", "sparse-checkout", "init", "--cone"], check=True)
    subprocess.run(["git", "sparse-checkout", "set"] + SPARSE_DIRS, check=True)
    subprocess.run(["git", "checkout"], check=True)

def cleanup_repo():
    print("Cleaning up unnecessary files...")
    for item in [".git", ".gitignore", "README.md", "LICENSE", "setup.py", "requirements.txt"]:
        item_path = os.path.join(DEST_DIR, item)
        if os.path.exists(item_path):
            if os.path.isdir(item_path):
                subprocess.run(["rm", "-rf", item_path])
            else:
                os.remove(item_path)

def main():
    print("Setting up ExLlamaV2 Utilities...")
    check_nvidia()
    check_conda_env()
    install_pypi_package()
    jit_compile()
    clone_repo()
    sparse_checkout()
    cleanup_repo()
    print("ExLlamaV2 Utilities setup complete!")

if __name__ == "__main__":
    main()

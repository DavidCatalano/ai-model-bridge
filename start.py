import argparse
import os
import subprocess
import sys
from typing import Optional


def install_dependencies(requirements_file: str, verbose: bool = False) -> None:
    """Install dependencies from a requirements file."""
    if not os.path.exists(requirements_file):
        print(f"Requirements file {requirements_file} not found.")
        raise FileNotFoundError(f"Missing: {requirements_file}")

    # Log environment and Python details
    with open("install.log", "w") as log_file:
        log_file.write(f"Python executable: {sys.executable}\n")
        log_file.write(f"Pip version: {subprocess.run([sys.executable, '-m', 'pip', '--version'], capture_output=True, text=True).stdout.strip()}\n")
        log_file.write("Environment variables:\n")
        log_file.write("\n".join([f"{k}={v}" for k, v in os.environ.items()]) + "\n\n")

        # Capture the current sys.path for debugging
        log_file.write("sys.path:\n")
        log_file.write("\n".join(sys.path) + "\n\n")

    # Upgrade pip
    pip_upgrade_cmd = [sys.executable, "-m", "pip", "install", "--upgrade", "pip"]
    if verbose:
        print("Running:", " ".join(pip_upgrade_cmd))
    subprocess.run(pip_upgrade_cmd, check=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)

    # Install dependencies
    install_cmd = [sys.executable, "-m", "pip", "install", "-r", requirements_file]
    if verbose:
        print("Running:", " ".join(install_cmd))
    result = subprocess.run(install_cmd, check=True, stderr=subprocess.PIPE, stdout=subprocess.PIPE)

    # Log pip installation output
    with open("install.log", "a") as log_file:
        log_file.write("Pip install output:\n")
        log_file.write(result.stdout.decode())
        log_file.write("\nPip install errors:\n")
        log_file.write(result.stderr.decode())

    # Confirm installation by listing installed packages
    installed_packages = subprocess.run([sys.executable, "-m", "pip", "list"], capture_output=True, text=True)
    with open("install.log", "a") as log_file:
        log_file.write("\nInstalled packages:\n")
        log_file.write(installed_packages.stdout)


# def start_interactive_shell() -> None:
#     """Drop the user into an interactive shell."""
#     # Get the active Conda environment name
#     conda_env = os.environ.get("CONDA_DEFAULT_ENV", "")
#     ps1_prefix = f"({conda_env}) " if conda_env else ""
#     print(f'Setting prompt: {ps1_prefix} {os.environ.get("PS1", "")}')
#     # Update the PS1 environment variable
#     os.environ["PS1"] = ps1_prefix + os.environ.get("PS1", "")
#     print("Entering interactive shell...")
#     os.execv("/bin/bash", ["/bin/bash"])
def start_interactive_shell() -> None:
    """Drop the user into an interactive shell."""
    # Get the active Conda environment name
    conda_env = os.environ.get("CONDA_DEFAULT_ENV", "")
    ps1_prefix = f"({conda_env}) " if conda_env else ""
    print(f'Setting prompt: {ps1_prefix}{os.environ.get("PS1", "")}')
    
    # Update the PS1 environment variable
    os.environ["PS1"] = ps1_prefix + os.environ.get("PS1", "")
    
    print("Entering interactive shell...")
    
    # Pass the updated environment to the new Bash shell
    os.execv("/usr/bin/env", ["env", "bash", "--login"])


def main() -> None:
    print(f"Using Python interpreter: {sys.executable}")
    parser = argparse.ArgumentParser(description="AI Model Bridge setup script.")
    parser.add_argument("--setup", action="store_true", help="Run setup tasks.")
    parser.add_argument("--interactive", action="store_true", help="Drop into an interactive shell.")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose output.")

    args = parser.parse_args()

    try:
        if args.setup:
            if args.verbose:
                print("Starting setup process...")
            requirements_file = "/home/app/ai-model-bridge/requirements.txt"
            install_dependencies(requirements_file, verbose=args.verbose)
            if args.verbose:
                print("Setup completed successfully.")

        if args.interactive:
            start_interactive_shell()

        if not args.setup and not args.interactive:
            parser.print_help()

    except Exception as e:
        print(f"Error: {e}")
        print("An error occurred. Dropping into interactive shell...")
        start_interactive_shell()


if __name__ == "__main__":
    main()

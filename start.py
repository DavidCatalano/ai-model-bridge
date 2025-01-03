import subprocess
import sys
import os
import argparse
from typing import Optional


def install_dependencies(requirements_file: str, verbose: bool = False) -> None:
    """Install dependencies from a requirements file."""
    if not os.path.exists(requirements_file):
        print(f"Requirements file {requirements_file} not found.")
        raise FileNotFoundError(f"Missing: {requirements_file}")

    pip_upgrade_cmd = [sys.executable, "-m", "pip", "install", "--upgrade", "pip"]
    install_cmd = [sys.executable, "-m", "pip", "install", "-r", requirements_file]

    if verbose:
        print("Running:", " ".join(pip_upgrade_cmd))
    subprocess.run(pip_upgrade_cmd, check=True)

    if verbose:
        print("Running:", " ".join(install_cmd))
    subprocess.run(install_cmd, check=True)


def start_interactive_shell() -> None:
    """Drop the user into an interactive shell."""
    print("Entering interactive shell...")
    os.execv("/bin/bash", ["/bin/bash"])


def main() -> None:
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

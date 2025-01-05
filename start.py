import argparse
import os
import subprocess
import sys


def install_dependencies(requirements_file: str, verbose: bool = False) -> None:
    """Install dependencies from a requirements file."""
    if not os.path.exists(requirements_file):
        print(f"Requirements file {requirements_file} not found.")
        raise FileNotFoundError(f"Missing: {requirements_file}")

    if verbose:
        # Log environment and Python details only if verbose is enabled
        with open("install.log", "w") as log_file:
            log_file.write(f"Python executable: {sys.executable}\n")
            log_file.write(
                f"Pip version: {subprocess.run([sys.executable, '-m', 'pip', '--version'], capture_output=True, text=True).stdout.strip()}\n"
            )
            log_file.write("Environment variables:\n")
            log_file.write("\n".join([f"{k}={v}" for k, v in os.environ.items()]) + "\n\n")
            log_file.write("sys.path:\n")
            log_file.write("\n".join(sys.path) + "\n\n")

    # Install dependencies
    subprocess.run([sys.executable, "-m", "pip", "install", "--upgrade", "pip"], check=True)
    subprocess.run([sys.executable, "-m", "pip", "install", "-r", requirements_file], check=True)


def start_interactive_shell() -> None:
    """Drop the user into an interactive shell."""
    print("Entering interactive shell...")
    os.execv("/bin/bash", ["/bin/bash"])


def keep_container_alive() -> None:
    """Keep the container alive."""
    print("Keeping the container alive. Press Ctrl+C to exit.")
    try:
        while True:
            pass
    except KeyboardInterrupt:
        print("Exiting nowebui mode.")


def start_webui() -> None:
    """Start the Gradio-based WebUI."""
    script_path = os.path.join(os.path.dirname(__file__), "web", "app.py")
    if not os.path.exists(script_path):
        print(f"WebUI script not found at {script_path}")
        sys.exit(1)

    print(f"Starting Gradio WebUI from {script_path}")
    subprocess.run([sys.executable, script_path], check=True)


def main() -> None:
    print(f"Using Python interpreter: {sys.executable}")
    parser = argparse.ArgumentParser(description="AI Model Bridge setup script.")
    parser.add_argument("--setup", action="store_true", help="Run setup tasks.")
    parser.add_argument("--interactive", action="store_true", help="Drop into an interactive shell.")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose output.")
    parser.add_argument("--nowebui", action="store_true", help="Keep the container alive without running a WebUI.")
    parser.add_argument("--webui", action="store_true", help="Launch the Gradio WebUI.")

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

        if args.nowebui:
            keep_container_alive()

        if args.webui:
            start_webui()

        if not any([args.setup, args.interactive, args.nowebui, args.webui]):
            parser.print_help()

    except Exception as e:
        print(f"Error: {e}")
        print("An error occurred. Dropping into interactive shell...")
        start_interactive_shell()


if __name__ == "__main__":
    main()

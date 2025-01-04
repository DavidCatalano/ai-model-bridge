#!/usr/bin/env bash
#set -e  # Exit immediately if a command exits with a non-zero status

# Pass all arguments to start_linux.sh
echo "Arguments passed to entrypoint.sh: $@"

# Source start_linux.sh to retain changes
source /home/app/ai-model-bridge/start_linux.sh "$@"

# Keep the process alive if no other commands are run
# exec "$@"

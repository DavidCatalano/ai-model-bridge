#!/usr/bin/env bash
set -e  # Exit if a command exits with a non-zero status

umask 0002  # Set umask to respect group permissions for newly created files

if [[ " $@ " =~ " --verbose " ]]; then
    echo "Arguments passed to entrypoint.sh: $@"
    echo "Current umask in entrypoint: $(umask)"
fi

# Source start_linux.sh to retain changes
source /home/app/ai-model-bridge/start_linux.sh "$@"

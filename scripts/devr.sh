#!/usr/bin/env bash

# Check if the first argument is "bashrc"
if [[ "$1" == "bashrc" ]]; then
    echo "Appending Conda environment activation to ~/.bashrc"
    echo "source /opt/ai-model-bridge/miniconda/conda/bin/activate && conda activate /opt/ai-model-bridge/miniconda/env" >> ~/.bashrc
    echo "Done. The environment will activate automatically when you start a new shell."
else
    echo "Usage: devr.sh bashrc"
    echo "Pass 'bashrc' as an argument to append Conda activation commands to ~/.bashrc."
fi

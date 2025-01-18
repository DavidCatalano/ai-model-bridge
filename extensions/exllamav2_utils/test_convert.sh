#!/usr/bin/env bash

python exllamav2_utils_repo/convert.py \
    -i /data/LLM/huggingface/hub/models--meta-llama--Llama-3.2-3B-Instruct/snapshots/0cb88a4f764b7a12671c53f0838cd831a0843b95/ \
    -o /data/fast/modelbridge/test03/ \
    -cf /data/fast/modelbridge/test03/ \
    -b 4.0

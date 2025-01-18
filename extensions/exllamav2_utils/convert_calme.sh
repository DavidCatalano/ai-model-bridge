#!/usr/bin/env bash

CUDA_VISIBLE_DEVICES=1 python exllamav2_utils_repo/convert.py \
    -i /data/fast/modelbridge/calme-3.2-instruct-78b-exl2/ \
    -o /data/fast/modelbridge/calme-3.2-instruct-78b-exl2-4.0-job/ \
    -cf /data/fast/modelbridge/calme-3.2-instruct-78b-exl2-4.0/ \
    -b 4.0

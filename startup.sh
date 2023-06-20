#!/bin/sh

(git -C . fetch || git clone https://github.com/jbaboval/stable-diffusion-webui .) && \
pip install -r requirements.txt

. /opt/intel/oneapi/setvars.sh && python ./launch.py "$@"

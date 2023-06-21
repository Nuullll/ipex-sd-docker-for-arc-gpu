#!/bin/sh

(git -C . fetch || git clone https://github.com/jbaboval/stable-diffusion-webui .) && \
pip -q install -r requirements.txt

python ./launch.py "$@"

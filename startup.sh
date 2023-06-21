#!/bin/sh

git -C . fetch || git clone https://github.com/vladmandic/automatic.git .

if [ ! -d /deps/venv ]; then
    echo "Creating venv with system packages (torch, ipex, etc)"
    python -m venv /deps/venv --system-site-packages
fi

export PATH=/deps/venv/bin:$PATH

python ./launch.py "$@"

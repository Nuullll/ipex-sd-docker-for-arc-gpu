#!/bin/sh
git rev-parse --git-dir > /dev/null 2>&1 || (git clone https://github.com/vladmandic/automatic.git . && git reset --hard 698c8d56cd9fedfca66aad762594adc8ffb6a4e7)
git config core.filemode false
./webui.sh "$@"

#!/bin/sh
git rev-parse --git-dir > /dev/null 2>&1 || (git clone https://github.com/vladmandic/automatic.git .)
git config core.filemode false
./webui.sh "$@"

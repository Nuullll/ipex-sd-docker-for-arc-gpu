#!/bin/sh
git -C . fetch || git clone https://github.com/vladmandic/automatic.git .
git config core.filemode false
./webui.sh "$@"

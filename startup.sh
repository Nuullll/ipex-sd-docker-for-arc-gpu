#!/bin/sh
git -C . fetch || git clone https://github.com/vladmandic/automatic.git .
./webui.sh "$@"
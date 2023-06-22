#!/bin/sh
git -C automatic fetch || git clone https://github.com/vladmandic/automatic.git
cd automatic
./webui.sh --use-ipex --listen
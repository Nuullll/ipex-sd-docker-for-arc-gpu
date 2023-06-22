#!/bin/sh
chown sd-webui:sd-webui /deps
chown sd-webui:sd-webui /sd-webui
exec runuser -u sd-webui "$@"
:: prepare packaging container
docker run -it `
--device /dev/dxg `
-v /usr/lib/wsl:/usr/lib/wsl `
-v $home\docker-mount\sd-webui-package:/sd-webui `
-v deps:/deps `
-v huggingface:/root/.cache/huggingface `
-p 7860:7860 `
--name sd-server-package `
nuullll/ipex-arc-sd:latest --upgrade

:: export image
docker save --output $home\projects\arc-sd-all-in-one\image.tar nuullll/ipex-arc-sd:latest

:: export volumes
docker run --rm --volumes-from sd-server-package -v $home\projects\arc-sd-all-in-one:/backup ubuntu tar cvf /backup/volume-deps.tar /deps
docker run --rm --volumes-from sd-server-package -v $home\projects\arc-sd-all-in-one:/backup ubuntu tar cvf /backup/volume-huggingface.tar /root/.cache/huggingface

:: package Web UI folder
powershell -command "Compress-Archive -Path $home\docker-mount\sd-webui-package\* -DestinationPath $home\projects\arc-sd-all-in-one\webui.zip"

:: copy install script
powershell -command "Copy-Item $home\projects\ipex-sd-docker-for-arc-gpu\scripts\install.bat -Destination $home\projects\arc-sd-all-in-one"

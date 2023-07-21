# upgrade SD.Next
docker run -it `
--device /dev/dxg `
-v /usr/lib/wsl:/usr/lib/wsl `
-v $home\docker-mount\sd-webui-package:/sd-webui `
-v deps:/deps `
-v huggingface:/root/.cache/huggingface `
-p 7866:7860 `
--name sd-server-package-upgrade `
ipex-arc-sd --upgrade

# Copy localizations folder until https://github.com/vladmandic/automatic/pull/1783 is merged
Copy-Item -Path "$home\docker-mount\localizations" -Destination "$home\docker-mount\sd-webui-package\localizations" -Recurse

# prepare packaging container
docker run -it `
--device /dev/dxg `
-v /usr/lib/wsl:/usr/lib/wsl `
-v $home\docker-mount\sd-webui-package:/sd-webui `
-v deps:/deps `
-v huggingface:/root/.cache/huggingface `
-p 7866:7860 `
--name sd-server-package `
ipex-arc-sd

# export image
docker save --output $home\projects\arc-sd-all-in-one\image.tar nuullll/ipex-arc-sd:latest

# export volumes
docker pull ubuntu
docker run --rm --volumes-from sd-server-package -v $home\projects\arc-sd-all-in-one:/backup ubuntu tar cvf /backup/volume-deps.tar /deps
docker run --rm --volumes-from sd-server-package -v $home\projects\arc-sd-all-in-one:/backup ubuntu tar cvf /backup/volume-huggingface.tar /root/.cache/huggingface

# package Web UI folder
# exclude sensitive/large files
# sdnext.log
Remove-Item $home\docker-mount\sd-webui-package\sdnext.log
# outputs
Remove-Item $home\docker-mount\sd-webui-package\outputs\* -Recurse
# ControlNet
Move-Item $home\docker-mount\sd-webui-package\models\ControlNet\* $home\docker-mount\sd-webui-package-exclude\models\ControlNet -Force
# ControlNet annotator
Move-Item $home\docker-mount\sd-webui-package\extensions-builtin\sd-webui-controlnet\annotator\downloads\* $home\docker-mount\sd-webui-package-exclude\extensions-builtin\sd-webui-controlnet\annotator\downloads -Force
# SD models
Move-Item $home\docker-mount\sd-webui-package\models\Stable-diffusion\* $home\docker-mount\sd-webui-package-exclude\models\Stable-diffusion -Force
# embeddings
Move-Item $home\docker-mount\sd-webui-package\models\embeddings\* $home\docker-mount\sd-webui-package-exclude\models\embeddings -Force
# Lora
Move-Item $home\docker-mount\sd-webui-package\models\Lora\* $home\docker-mount\sd-webui-package-exclude\models\Lora -Force
# LyCORIS
Move-Item $home\docker-mount\sd-webui-package\models\LyCORIS\* $home\docker-mount\sd-webui-package-exclude\models\LyCORIS -Force

## Compress
Compress-Archive -Path $home\docker-mount\sd-webui-package\* -DestinationPath $home\projects\arc-sd-all-in-one\webui.zip

# copy install script
Copy-Item $home\projects\ipex-sd-docker-for-arc-gpu\scripts\install.bat -Destination $home\projects\arc-sd-all-in-one

## Package
Compress-Archive -Path $home\projects\arc-sd-all-in-one\* -DestinationPath $home\projects\artifacts\Arc-AI绘画-安装包-v0.5.0.zip

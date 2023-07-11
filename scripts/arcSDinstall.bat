@echo off
setlocal enableextensions

winget install docker.dockerdesktop

If %ERRORLEVEL% EQU 0 (
    cmd /k "%0"
)
::if the package is successfully installed, open a new cmd to run this script again



If %ERRORLEVEL% EQU -1978335189 (
    ::If the package is already installed and has no update
    goto :continue
) ELSE (
    ::other errors
    goto :EOF
)


:continue
echo Please OPEN DOCKER DESKTOP then config the proxies (if needed).
echo Where do you wanna install sd-webui? Your models and pictures will be there. (default=%UserProfile%\docker-mount\sd-webui)
set /p loc=
If "%loc%" == "" (
    @set loc=%UserProfile%\docker-mount\sd-webui
)

docker run -it ^
--device /dev/dxg ^
-v /usr/lib/wsl:/usr/lib/wsl ^
-v %loc%:/sd-webui ^
-v deps:/deps ^
-v huggingface:/root/.cache/huggingface ^
-p 7860:7860 ^
--name sd-server ^
nuullll/ipex-arc-sd:latest
:EOF
pause

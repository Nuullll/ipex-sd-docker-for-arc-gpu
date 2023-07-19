@echo off
setlocal
chcp 65001

@set delim===================================================
::Install Docker Desktop
echo %delim%
echo Checking Docker Desktop environment ...
echo 正在检查Docker Desktop环境 ...

winget install docker.dockerdesktop
if %ERRORLEVEL% EQU 0 (
    echo Installed Docker Desktop successfully!
    echo 成功安装Docker Desktop!
    echo Please re-execute this script after REBOOTing your system
    echo 请重启你的系统后重新执行此脚本
    pause
    exit
) else if %ERRORLEVEL% EQU -1978335189 (
    echo Docker Desktop is up-to-date!
    echo Docker Desktop已是最新版!
)

::Launch Docker Desktop
:LAUNCH_DD
echo %delim%
set dd_exe=C:\Program Files\Docker\Docker\Docker Desktop.exe
echo Launching Docker Desktop ... [The GUI will pop up]
echo 正在启动Docker Desktop ... [会弹出图形界面]
if exist "%dd_exe%" (
    start "" "%dd_exe%"
    echo Continue after Docker Desktop is launched successfully [The GUI will pop up]
    echo 请在Docker Desktop成功启动后继续 [会弹出图形界面]
    pause
) else (
    echo Didn't find Docker Desktop executable in the default location, please launch Docker Desktop manually!
    echo 未在默认安装位置找到Docker Desktop程序, 请手动启动Docker Desktop!
    pause
)

::Check docker daemon status
docker image ls 2>&1 | findstr "error during connect" >NUL
if %ERRORLEVEL% EQU 0 (
    echo Docker daemon is not running! Please wait until Docker Desktop is fully launched. [The GUI will pop up]
    echo Docker服务未启动! 请等待Docker Desktop完全启动后再继续 [会弹出图形界面]
    goto :LAUNCH_DD
)

::Import image
::Will automatically skip if the image 'nuullll/ipex-arc-sd:latest' already exists
echo %delim%
echo Importing docker image: nuullll/ipex-arc-sd:latest from image.tar ...
echo 正在从image.tar导入nuullll/ipex-arc-sd:latest镜像 ...
docker load --input image.tar

::Import volumes
echo %delim%
echo Importing volumes ...
echo 正在导入数据卷 ...

::Check existence first
docker volume ls -f name=deps -f name=huggingface | findstr "local" >NUL
if %ERRORLEVEL% EQU 0 (
    echo WARNING: local volumes deps, huggingface already exist, the content would be overwritten!
    echo 警告: 本地数据卷 deps, huggingface 已存在, 内容将被覆盖!
    pause
)

docker run --rm ^
-v %cd%:/backup ^
-v deps:/deps ^
-v huggingface:/root/.cache/huggingface ^
--entrypoint bash ^
nuullll/ipex-arc-sd:latest ^
-c "cd /deps && tar xvf /backup/volume-deps.tar --strip 1 && cd /root/.cache/huggingface && tar xvf /backup/volume-huggingface.tar --strip 1"
echo Imported (python dependencies) volumes!
echo 成功导入(python依赖包)数据卷!

::Setup Web UI folder
:WEBUI
echo %delim%
echo Where do you want to install Stable Diffusion Web UI (to place the Web UI source code, models, outputs, etc)?
echo 想把Stable Diffusion Web UI安装到哪里? (用于放置Web UI源代码, 模型文件, 输出图片等)
echo Default(默认): %UserProfile%\docker-mount\sd-webui
set /p loc=
if "%loc%" == "" (
    @set loc=%UserProfile%\docker-mount\sd-webui
)

::Check folder status
if exist %loc% (
    echo ERROR: Folder already exists! Please specify a different path or remove the folder %loc%
    echo 错误: 目录已存在! 请指定其他路径或者删除文件夹 %loc%
    goto :WEBUI
)

echo %delim%
echo Extracting Web UI to %loc%
echo 正在将Web UI解压至 %loc%
powershell -command "Expand-Archive -Path %cd%\webui.zip -DestinationPath %loc%"

cls
echo %delim%
echo Extracted to: %loc%
echo 解压成功: %loc%
echo %delim%
echo Now you can manually copy your model files into corresponding locations under %loc% (e.g. %loc%\models\Stable-diffusion)
echo 现在你可以把模型文件手动复制到 %loc% 目录下相应位置了 (比如 %loc%\models\Stable-diffusion)
pause

::Launch Web UI for the first time
set container_name=sd-server
:LAUNCH_WEBUI
echo %delim%
echo Creating container: %container_name% ...
echo 正在创建容器: %container_name% ...
::Check name first
docker container ls -a -f name=%container_name% | findstr "%container_name%"
if %ERRORLEVEL% EQU 0 (
    echo The name '%container_name%' is used by the other container, please specify a new name:
    echo 已有其他容器占用了'%container_name%'这个名字, 请指定一个新名字:
    set /p container_name=
    if "%container_name%" == "sd-server" (
        set container_name=new-sd-server
    )
    goto :LAUNCH_WEBUI
)

echo Launching Web UI (container: %container_name%)...
echo 正在启动Web UI (容器: %container_name%)...
docker run -it ^
--device /dev/dxg ^
-v /usr/lib/wsl:/usr/lib/wsl ^
-v %loc%:/sd-webui ^
-v deps:/deps ^
-v huggingface:/root/.cache/huggingface ^
-p 7860:7860 ^
--name %container_name% ^
nuullll/ipex-arc-sd:latest
pause

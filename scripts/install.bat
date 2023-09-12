@echo off
setlocal enableextensions enabledelayedexpansion
chcp 65001 >NUL

@set delim===================================================
set cwd=%~dp0

::Lanuage selection
:LANG_SEL
cls
echo %delim%
echo 请选择此安装脚本的语言:
echo Please select the lanuage for this installation script:
echo %delim%
echo [1] 简体中文
echo [2] English
echo %delim%
echo.
set /p LANG=输入1或2, 然后按回车 (Type 1 or 2 then press ENTER): 
if "!LANG!" == "" set LANG=1
if not "!LANG!" == "1" if not "!LANG!" == "2" goto :LANG_SEL

::Check System status
echo.
echo %delim%
call :Print "正在检测系统环境 ..." , "Checking system environment ..."

wmic path win32_VideoController get name | findstr "Arc"
wmic path win32_VideoController get name | findstr "UHD" >NUL
if %ERRORLEVEL% EQU 0 call :PrintRed "核显独显同时打开可能在运行Stable Diffusion时引起错误  建议在设备管理器或BIOS中禁用核显!" , "iGPU + dGPU combination may cause errors when running Stable Diffusion. Suggest to disable iGPU in device manager or BIOS"

::Update WSL
call :Print "正在更新WSL ..." , "Updating WSL ..."
wsl --update
if not %ERRORLEVEL% EQU 0 call :PrintRed "WSL更新失败 后续安装Docker Desktop可能失败!", "Failed to update WSL. Docker Desktop installation may fail"

::Get total RAM size
set /a UNIT_MB=1024*1024
set /a UNIT_MB1=UNIT_MB/100
for /f "skip=1" %%p in ('wmic computersystem get TotalPhysicalMemory') do (
    set TOTAL_RAM=%%p
    goto :RAM_DONE
)

:RAM_DONE
set TOTAL_RAM1=%TOTAL_RAM:~0,-2%
set /a TOTAL_RAM_MB=TOTAL_RAM1/UNIT_MB1
set /a WSL_RAM=TOTAL_RAM_MB/2
call :Print "WSL的默认内存限制为系统物理内存[!TOTAL_RAM_MB! MB]的一半[!WSL_RAM! MB]" , "Default memory limit for WSL is half [!WSL_RAM! MB] of the total physical RAM size [!TOTAL_RAM_MB! MB]"
::Check minimum WSL RAM requirement
set /a WSL_RAM_REQ=13000
set WSL_CONFIG=%USERPROFILE%\.wslconfig
if !WSL_RAM! LEQ !WSL_RAM_REQ! (
    call :PrintRed "WSL的默认内存限制太低. 可能无法正常运行Stable Diffusion Web UI." , "Default memory limit for WSL is too low to run Stable Diffusion Web UI."
    if !TOTAL_RAM_MB! LSS !WSL_RAM_REQ! (
        set /a WSL_RAM_REQ=TOTAL_RAM_MB
        call :PrintRed "警告: 系统内存太低. 可能无法正常运行." , "WARNING: Total physical RAM size is low. Might not work."
    )

    call :PrintRed "是否要自动将WSL内存上限设置为 !WSL_RAM_REQ! MB?" , "Do you want to automatically adjust WSL memory limit to !WSL_RAM_REQ! MB?"
    set /p AUTO_WSL_RAM=输入y或N, 然后按回车 ^(Type y or N then press ENTER^): 
    if "!AUTO_WSL_RAM!" == "n" goto :CHECK_DD
    if "!AUTO_WSL_RAM!" == "N" goto :CHECK_DD

    if exist "!WSL_CONFIG!" (
        call :PrintRed "!WSL_CONFIG!已存在. 请手动修改后继续." , "!WSL_CONFIG! already exist. Please edit it manually."
        echo.
        call :Print ".wslconfig 示例" , "Example .wslconfig"
        echo.
        echo ^[wsl2^]
        echo memory=!WSL_RAM_REQ!MB
        echo.
    ) else (
        (
            echo ^[wsl2^]
            echo memory=!WSL_RAM_REQ!MB
        )>!WSL_CONFIG!
        call :Print "已成功生成文件 !WSL_CONFIG!" , "Successfully generated !WSL_CONFIG!"
    )
    start "" notepad.exe "!WSL_CONFIG!"

    echo .
    call :PrintRed "需要重新启动WSL服务才能生效. 是否现在重启WSL服务?" , "WSL backend needs to be restarted to allow the new config to take effect. Do you want to restart WSL backend now?"

    set /p SHUTDOWN_WSL=输入y或N, 然后按回车 ^(Type y or N then press ENTER^): 
    if "!SHUTDOWN_WSL!" == "n" goto :CHECK_DD
    if "!SHUTDOWN_WSL!" == "N" goto :CHECK_DD

    wsl --shutdown
)
echo.
call :PrintGreen "系统环境检查完成" , "Done checking system environment"
call :Print "按回车继续" , "Press ENTER to continue"
pause >NUL

::Install Docker Desktop
:CHECK_DD
echo.
echo %delim%
call :PrintRed "是否要自动安装/更新Docker Desktop?" , "Do you want to install/upgrade Docker Desktop automatically?"
set /p INSTALL_DD=输入y或N, 然后按回车 (Type y or N then press ENTER): 
if "!INSTALL_DD!" == "n" goto :LAUNCH_DD
if "!INSTALL_DD!" == "N" goto :LAUNCH_DD

call :Print "正在检查Docker Desktop环境 ..." , "Checking Docker Desktop environment ..."

winget install docker.dockerdesktop
echo.
if %ERRORLEVEL% EQU 0 (
    call :PrintGreen "成功安装Docker Desktop" , "Installed Docker Desktop successfully"
    call :PrintRed "请重启系统后重新执行此脚本" , "Please re-execute this script after REBOOTing your system"
    call :PrintRed "按任意键退出脚本" , "Press any key to exit"
    pause >NUL
    exit
) else if %ERRORLEVEL% EQU -1978335189 (
    call :PrintGreen "Docker Desktop已是最新版" , "Docker Desktop is up-to-date"
)

::Launch Docker Desktop
:LAUNCH_DD
echo.
echo %delim%
set dd_exe=C:\Program Files\Docker\Docker\Docker Desktop.exe
call :Print "正在启动Docker Desktop ..." , "Launching Docker Desktop ..."
if exist "!dd_exe!" (
    start "" "!dd_exe!"
) else (
    call :PrintRed "未在默认安装位置找到Docker Desktop程序. 请手动启动Docker Desktop" , "Didn't find Docker Desktop executable in the default location. please launch Docker Desktop manually"
)
call :PrintRed "请在图形界面弹出且docker engine启动完成后. 按任意键继续" , "When GUI pops up and docker engine is up. THEN press any key to continue"
pause >NUL

::Check docker daemon status
docker image ls 2>&1 | findstr "error during connect" >NUL
if %ERRORLEVEL% EQU 0 (
    call :PrintRed "Docker服务未启动. 请等待Docker Desktop完全启动后再继续" , "Docker daemon is not running. Please wait until Docker Desktop is fully launched."
    goto :LAUNCH_DD
)

::Import image
::Will automatically skip if the image 'nuullll/ipex-arc-sd:latest' already exists
echo.
echo %delim%
call :Print "正在从image.tar导入nuullll/ipex-arc-sd镜像 ..." , "Importing docker image: nuullll/ipex-arc-sd from image.tar ..."
docker load --input %cwd%\image.tar
if not %ERRORLEVEL% EQU 0 (
    call :PrintRed "导入本地镜像失败" , "Failed to import the local image"
    call :PrintRed "请确认脚本路径 %cwd% 不包含空格!" , "Please make sure there's no 'space' character in path %cwd%"
    call :Print "按任意键退出" , "Press any key to exit"
    pause >NUL
    exit
)
call :PrintGreen "成功导入镜像" , "Successfully imported the image"

::Import volumes
echo.
echo %delim%
call :Print "正在导入数据卷 ..." , "Importing volumes ..."

::Check existence first
docker volume ls -f name=deps-%%IMAGE_VER%% | findstr "local" >NUL
if %ERRORLEVEL% EQU 0 (
    call :PrintRed "警告: 本地数据卷 deps-%%IMAGE_VER%% 已存在" , "WARNING: local volumes deps-%%IMAGE_VER%% already exist, the content would be overwritten"
    call :PrintRed "是否要覆盖本地数据卷?" , "Do you want to overwrite local volumes?"
    set /p OVERWRITE_VOLUME=输入y或N, 然后按回车 ^(Type y or N then press ENTER^): 
    if "!OVERWRITE_VOLUME!" == "n" goto :WEBUI
    if "!OVERWRITE_VOLUME!" == "N" goto :WEBUI
    docker volume rm deps-%%IMAGE_VER%% -f >NUL
)

call :Print "解压中... 可能需要几分钟" , "Extracting ... may take several minutes"
docker run --rm ^
-v %cwd%:/backup ^
-v deps-%%IMAGE_VER%%:/deps ^
-v huggingface:/root/.cache/huggingface ^
--entrypoint bash ^
nuullll/ipex-arc-sd:v%%IMAGE_VER%% ^
-c "cd /deps && tar xf /backup/volume-deps.tar --totals --strip 1 && cd /root/.cache/huggingface && tar xf /backup/volume-huggingface.tar --totals --strip 3"
if not %ERRORLEVEL% EQU 0 (
    call :PrintRed "导入本地数据卷失败" , "Failed to import local volumes"
    call :Print "按任意键退出" , "Press any key to exit"
    pause >NUL
    exit
)
call :PrintGreen "成功导入数据卷" , "Successfully imported volumes"

::Setup Web UI folder
:WEBUI
echo.
echo %delim%
call :Print "正在复制Web UI目录 ..." , "Copying Web UI folder ..."
call :PrintRed "想把Web UI目录安装到哪里? [用于放置Web UI源代码 模型文件 输出图片等]" , "Where do you want to install Stable Diffusion Web UI [to place the Web UI source code | models | outputs etc]?"
call :PrintGreen "默认路径为 %USERPROFILE%\docker-mount\sd-webui" , "Default path %USERPROFILE%\docker-mount\sd-webui"
call :PrintRed "请勿输入带空格的路径" , "Don't use path with spaces"
set /p loc=输入安装路径 (Input install path): 
if "!loc!" == "" set loc=%USERPROFILE%\docker-mount\sd-webui
echo !loc! | findstr : >NUL
if not %ERRORLEVEL% EQU 0 (
    call :PrintRed "请输入正确的绝对路径. 例如 D:\ARC-AI" , "Please specify a correct absolute path. For example D:\ARC-AI"
    goto :WEBUI
)

::Check folder status
if exist !loc! (
    call :PrintRed "警告: 指定路径已存在 !loc!", "WARNING: Specified path already exists !loc!"
    call :PrintRed "是否要用新文件覆盖原有同名文件?" , "Do you want to overwrite conflicting files?"
    set /p FORCE_EXTRACT=输入y或N, 然后按回车 ^(Type y or N then press ENTER^): 
    if "!FORCE_EXTRACT!" == "n" goto :CONFIRM
    if "!FORCE_EXTRACT!" == "N" goto :CONFIRM
)
goto :EXTRACT

:CONFIRM
call :PrintRed "是否要跳过Web UI解压 [输入N重新选择解压路径]" , "Skip extracting Web UI foler [Input N to choose install path again]"
set /p SKIP_EXTRACT=输入y或N, 然后按回车 ^(Type y or N then press ENTER^): 
if "!SKIP_EXTRACT!" == "n" goto :WEBUI
if "!SKIP_EXTRACT!" == "N" goto :WEBUI
goto :WARMUP

:EXTRACT
echo.
echo %delim%
call :Print "正在将Web UI复制至 !loc!" , "Copying Web UI to !loc!"
robocopy %cwd%\webui !loc! /e /mt /z
echo.
call :PrintGreen "复制成功: !loc!" , "Copied to: !loc!"

echo.
echo %delim%
call :PrintGreen "现在请把你自己下载的SD大模型文件手动复制到 !loc!\models\Stable-diffusion" , "Now you can manually copy your model files into corresponding locations under !loc! [e.g. !loc!\models\Stable-diffusion]"
call :Print "按回车继续" , "Press ENTER to continue"
pause >NUL

::Warmup Web UI
:WARMUP
echo.
echo %delim%
call :Print "正在初始化Web UI ... 可能需要几分钟" , "Initializing Web UI ... may take several minutes"

for /f "tokens=*" %%g in ('docker run -d ^
--device /dev/dxg ^
-v /usr/lib/wsl:/usr/lib/wsl ^
-v !loc!:/sd-webui ^
-v deps-%%IMAGE_VER%%:/deps ^
-v huggingface:/root/.cache/huggingface ^
-p 7860:7860 ^
--rm ^
nuullll/ipex-arc-sd:v%%IMAGE_VER%% ^
--no-hashing') do (set container_id=%%g)

set /a i=0
:WARMUP_CHECK
findstr "Startup time" "!loc!\sdnext.log" >NUL 2>NUL
if %ERRORLEVEL% EQU 0 (
    docker stop !container_id! >NUL
    call :PrintGreen "初始化成功" , "Initialized successfully"
    goto :WARMUP_DONE
)
timeout /t 10 /nobreak >NUL
set /a i=i+10
if !i! GEQ 120 (
    docker stop !container_id! >NUL
    call :PrintRed "警告: Web UI初始化超时 [120秒]" , "WARNING: Web UI initialization timeout [120s]"
    call :PrintRed "请查看日志 !loc!\sdnext.log" , "Please check the log !loc!\sdnext.log"
    goto :WARMUP_DONE
)
goto :WARMUP_CHECK
:WARMUP_DONE

::Launch Web UI for the first time
set container_name=sd-server-%%CONTAINER_VER%%
:LAUNCH_WEBUI
echo.
echo %delim%
call :Print "正在创建容器: !container_name! ..." , "Creating container: !container_name! ..."
::Check name first
docker container ls -a -f name=!container_name! | more | findstr /rc:" !container_name!$">NUL
if %ERRORLEVEL% EQU 0 (
    call :PrintRed "已有其他容器占用了'!container_name!'这个名字" , "The name '!container_name!' is used by the other container"
    set /p container_name=请指定一个新名字 ^(Please specify a new name^): 
    if "!container_name!" == "sd-server" set container_name=new-sd-server
    goto :LAUNCH_WEBUI
)

call :PrintGreen "正在启动Web UI [容器: !container_name!]..." , "Launching Web UI [container: !container_name!]..."
docker run -it ^
--device /dev/dxg ^
-v /usr/lib/wsl:/usr/lib/wsl ^
-v !loc!:/sd-webui ^
-v deps-%%IMAGE_VER%%:/deps ^
-v huggingface:/root/.cache/huggingface ^
-p 7860:7860 ^
--name !container_name! ^
nuullll/ipex-arc-sd:v%%IMAGE_VER%%
exit

:Print
if !LANG! == 1 (echo %~1 ) else echo %~2
exit /b 0

:PrintRed
if !LANG! == 1 (
    powershell write-host -fore Red %~1
) else (
    powershell write-host -fore Red %~2
)
exit /b 0

:PrintGreen
if !LANG! == 1 (
    powershell write-host -fore Green %~1
) else (
    powershell write-host -fore Green %~2
)
exit /b 0

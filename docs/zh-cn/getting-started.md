# 开始使用

中国用户看过来，这里还有一版[视频教程](https://www.bilibili.com/video/BV1Ek4y1u7Z4/)在B站。

## 前置需求

* 在你的系统上安装[Docker Desktop](https://www.docker.com/)。
  - 如果你使用的是Windows，请确认使用的是默认的基于WSL2的docker引擎。你可以在Docker Desktop图形界面中前往`Setting（设置） -> General（通用）` 检查`Use the WSL 2 based engine`选项是否勾选。
* 良好的（且科学的）网络连接。:surfer:

## 使用远程镜像启动docker容器

<!-- tabs:start -->

### **Windows**

```powershell
docker run -it `
--device /dev/dxg `
-v /usr/lib/wsl:/usr/lib/wsl `
-v $home\docker-mount\sd-webui:/sd-webui `
-v deps:/deps `
-p 7860:7860 `
--name sd-server `
nuullll/ipex-arc-sd:latest
```

### **Linux**

```bash
docker run -it \
--device /dev/dri \
-v ~/docker-mount/sd-webui:/sd-webui \
-v deps:/deps \
-p 7860:7860 \
--name sd-server \
nuullll/ipex-arc-sd:latest
```

<!-- tabs:end -->

如果你对docker还不太熟悉，我们来看一下这一长串命令究竟在做什么：

- [`docker run`](https://docs.docker.com/engine/reference/commandline/run/)通过一个镜像来创建并运行**一个新容器**。
- 最后一个参数`nuullll/ipex-arc-sd:latest`指定了镜像，格式是`<image_name>:<tag>`。如果在本地没有找到这个镜像，docker会尝试从[DockerHub远程](https://hub.docker.com/r/nuullll/ipex-arc-sd)拉取。
- `--name sd-server`给新创建的容器指定了一个有意义的名字（比如`sd-server`）。这个参数很有用但不是必须的。
- `-it`会在容器启动后生成一个可交互的命令行。强烈建议使用这个选项，因为我们可能需要通过命令行的日志输出来监控Web UI的状态。
- 在linux中，需要使用`--device /dev/dri`来授权容器访问你的显卡。在windows中，需要同时使用`--device /dev/dxg`和`-v /usr/lib/wsl:/usr/lib/wsl`来授权容器访问你的显卡。详见[wslg示例](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md#containerized-applications-access-to-the-vgpu)。
- `-v <host_mount_dir>:/sd-webui`指定了需要被[绑定挂载](https://docs.docker.com/storage/bind-mounts/)到容器`/sd-webui`路径的宿主机目录。在第一次启动容器时，应当指定一个宿主机上的**空目录或不存在的目录**作为`<host_mount_dir>`，使得容器能够将[SD.Next](https://github.com/vladmandic/automatic)的源代码下载到该目录。如果你想另起一个新容器（比如[覆盖镜像的entrypoint](https://docs.docker.com/engine/reference/run/#entrypoint-default-command-to-execute-at-runtime)）同时共享着已经被其他容器初始化过的Web UI目录，应当指定相同的`<host_mount_dir>`。
- `-v <volume_name>:/deps`指定了一个由docker引擎管理的[数据卷](https://docs.docker.com/storage/volumes/)（例如，名为`deps`的数据卷），并将其挂载到容器内部的`/deps`目录。`/deps`会成为python虚拟环境的根目录（见[`Dockerfile: ENV venv_dir`](https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/blob/main/Dockerfile)），用于存放Web UI启动后需要用到的动态python依赖项（例如Web UI扩展所需要的包）。你可以将`deps`数据卷挂载到多个容器，那么这些动态依赖项只需要下载和安装一次。对于想以不同Web UI参数（比如`--debug`）运行容器的用户以及本地创建docker镜像的开发者来说，这很有用。
- `-p <host_port>:7860`指定了[端口映射](https://docs.docker.com/network/)。容器内运行于7860端口的Web UI服务会被转发至宿主机上的`http://localhost:<host_port>`。

### 预期结果

<!-- tabs:start -->

#### **从DockerHub拉取镜像**

这可能会花一些时间，但这是一劳永逸的设置，除非你以后想将镜像升级到新版本。喝杯咖啡休息一下！

```txt
docker run -it `
>> --device /dev/dxg `
>> -v /usr/lib/wsl:/usr/lib/wsl `
>> -v $home\docker-mount\sd-webui:/sd-webui `
>> -v deps:/deps `
>> -p 7860:7860 `
>> --name sd-server `
>> nuullll/ipex-arc-sd:latest
Unable to find image 'nuullll/ipex-arc-sd:latest' locally
latest: Pulling from nuullll/ipex-arc-sd
6b851dcae6ca: Already exists
2614e0cfd126: Pull complete
b7f3f70e6e79: Downloading [==========>                                        ]  133.2MB/632.5MB
855ff6ba44ef: Download complete
63a57d250c21: Download complete
27dc2936b164: Download complete
f5b66ca8a170: Download complete
7a2fe23e57b6: Download complete
b88d41ac9d88: Download complete
ea324f812f19: Download complete
0e31e3e1e212: Download complete
93d440be2069: Downloading [========================================>          ]  68.26MB/83.51MB
08aa679dcc94: Download complete
4315cf4ec169: Download complete
693801fa781b: Download complete
```

成功后你会看到以下信息：

```txt
Status: Downloaded newer image for nuullll/ipex-arc-sd:latest
```

#### **下载[SD.Next](https://github.com/vladmandic/automatic)源代码**

```txt
fatal: not a git repository (or any parent up to mount point /)
Stopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).
Cloning into '.'...
remote: Enumerating objects: 27569, done.
remote: Counting objects: 100% (214/214), done.
remote: Compressing objects: 100% (99/99), done.
remote: Total 27569 (delta 129), reused 183 (delta 114), pack-reused 27355
Receiving objects: 100% (27569/27569), 34.77 MiB | 3.35 MiB/s, done.
Resolving deltas: 100% (19625/19625), done.
Updating files: 100% (272/272), done.
```

你可能注意到了第一行有个严重错误`fatal: not a git repository`。没事，这是正常现象。因为我们首次将一个宿主机上的空目录或不存在的目录挂载作为Web UI的目录。脚本会向该目录中下载[SD.Next](https://github.com/vladmandic/automatic)的代码。

#### **启动Web UI服务**

Web UI会首次尝试安装python依赖项。

所有python包都会安装到docker数据卷`deps`（通过`-v deps:/deps`选项指定的），数据卷里的数据是**持久化的**。因此每个依赖项只会被下载安装一次，除非你手动移除`deps`数据卷或者给容器挂载一个新的数据卷。

```txt
Create and activate python venv
Launching launch.py...
06:37:21-673336 INFO     Starting SD.Next
06:37:21-679480 INFO     Python 3.10.6 on Linux
06:37:21-762667 INFO     Version: 205b5164 Fri Jul 7 22:41:26 2023 +0300
06:37:21-822410 INFO     Intel OneAPI Toolkit detected   <<<<<------------ 成功检测到了镜像中的oneAPI环境！
06:37:21-825165 INFO     Installing package: torch==1.13.0a0 torchvision==0.14.1a0
                         intel_extension_for_pytorch==1.13.120+xpu -f https://developer.intel.com/ipex-whl-stable-xpu   <<<<<------------ 为英特尔XPU安装torch和ipex！
06:39:59-352248 INFO     Torch 1.13.0a0+gitb1dde16
/deps/venv/lib/python3.10/site-packages/torchvision/io/image.py:13: UserWarning: Failed to load image Python extension:
  warn(f"Failed to load image Python extension: {e}")   <<<<<------------ 警告只是警告
06:39:59-901569 INFO     Torch backend: Intel IPEX 1.13.120+xpu   <<<<<------------ 使用了IPEX XPU后端
/bin/sh: 1: icpx: not found   <<<<<------------ 没事，这个不用管
06:39:59-905688 INFO
06:39:59-908720 INFO     Torch detected GPU: Intel(R) Graphics [0x56a0] VRAM 13005 Compute Units 512   <<<<<------------ 检测到了你的锐炫显卡！（0x56a0是Arc A770的设备识别码）
06:39:59-910747 INFO     Installing package: tensorflow==2.12.0
06:42:27-193632 INFO     Verifying requirements
06:42:27-199643 INFO     Installing package: addict
06:42:31-869764 INFO     Installing package: aenum
06:42:36-004535 INFO     Installing package: aiohttp
06:42:49-502038 INFO     Installing package: anyio
06:42:54-800093 INFO     Installing package: appdirs
06:42:57-293693 INFO     Installing package: astunparse
06:42:58-683720 INFO     Installing package: bitsandbytes
06:43:32-072033 INFO     Installing package: blendmodes
06:43:41-571773 INFO     Installing package: clean-fid
06:43:45-510400 INFO     Installing package: easydev
06:43:52-898981 INFO     Installing package: extcolors
06:43:55-996995 INFO     Installing package: facexlib
06:45:06-051191 INFO     Installing package: filetype
06:45:08-795192 INFO     Installing package: future
06:45:13-184420 INFO     Installing package: gdown
06:45:18-665094 INFO     Installing package: gfpgan
...
06:53:42-651633 INFO     Installing repositories
06:53:42-661095 INFO     Cloning repository: https://github.com/Stability-AI/stablediffusion.git
06:54:10-838284 INFO     Cloning repository: https://github.com/CompVis/taming-transformers.git
06:55:29-401387 INFO     Cloning repository: https://github.com/crowsonkb/k-diffusion.git
06:55:33-136352 INFO     Cloning repository: https://github.com/sczhou/CodeFormer.git
06:55:46-026258 INFO     Cloning repository: https://github.com/salesforce/BLIP.git
06:55:51-501455 INFO     Installing submodules
07:20:37-262294 INFO     Extension installed packages: sd-webui-agent-scheduler ['SQLAlchemy==2.0.18',
                         'greenlet==2.0.2']
07:21:17-718747 INFO     Extension installed packages: sd-webui-controlnet ['lxml==4.9.3', 'reportlab==4.0.4',
                         'pycparser==2.21', 'portalocker==2.7.0', 'cffi==1.15.1', 'svglib==1.5.1', 'tinycss2==1.2.1',
                         'mediapipe==0.10.1', 'tabulate==0.9.0', 'cssselect2==0.7.0', 'webencodings==0.5.1',
                         'sounddevice==0.4.6', 'iopath==0.1.9', 'yacs==0.1.8', 'fvcore==0.1.5.post20221221']
07:21:17-825317 INFO     Extensions enabled: ['a1111-sd-webui-lycoris', 'clip-interrogator-ext', 'LDSR', 'Lora',
                         'multidiffusion-upscaler-for-automatic1111', 'ScuNET', 'sd-dynamic-thresholding',
                         'sd-extension-system-info', 'sd-webui-agent-scheduler', 'sd-webui-controlnet',
                         'stable-diffusion-webui-images-browser', 'stable-diffusion-webui-rembg', 'SwinIR']
07:21:18-037617 INFO     Extension preload: 0.2s /sd-webui/extensions-builtin
07:21:18-043483 INFO     Extension preload: 0.0s /sd-webui/extensions
07:21:18-049065 INFO     Server arguments: ['-f', '--use-ipex', '--listen']
No module 'xformers'. Proceeding without it.
07:21:25-915862 INFO     Libraries loaded
07:21:26-122879 INFO     Using data path: /sd-webui
07:21:26-219703 INFO     Available VAEs: /sd-webui/models/VAE 0
07:21:26-278684 INFO     Available models: /sd-webui/models/Stable-diffusion 0
```

#### **下载默认模型**

```txt
Download the default model? (y/N)
```

当你看到这行提示，如果你需要默认模型的话，输入`y`。

或者直接把你喜欢的模型复制到`$home\docker-mount\sd-webui\models\Stable-diffusion`路径下。注意`$home\docker-mount\sd-webui`就是`-v <host_mount_dir>:/sd-webui`选项中指定的`<host_mount_dir>`。

#### **全部搞定！**

现在可以用你最爱的浏览器在宿主机上打开Web UI啦！

[http://localhost:7860/](http://localhost:7860/)

享受你的Stable Diffusion之旅！:fire:

```txt
07:42:49-061422 INFO     ControlNet v1.1.227
ControlNet preprocessor location: /sd-webui/extensions-builtin/sd-webui-controlnet/annotator/downloads
07:42:49-687272 INFO     ControlNet v1.1.227
07:42:50-912721 INFO     Loading UI theme: name=black-orange style=Auto
Running on local URL:  http://0.0.0.0:7860
07:42:53-611671 INFO     Local URL: http://localhost:7860/
07:42:53-616045 INFO     Initializing middleware
07:42:53-761013 INFO     [AgentScheduler] Task queue is empty
07:42:53-762931 INFO     [AgentScheduler] Registering APIs
07:42:53-837492 INFO     Model metadata saved: /sd-webui/metadata.json 1
07:42:53-947057 WARNING  Selected checkpoint not found: model.ckpt
07:42:54-048539 WARNING  Loading fallback checkpoint: v1-5-pruned-emaonly.safetensors
Loading weights: /sd-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors ━━━━━━━━━━━━━━━━━━ 0.0/4.3 GB -:--:--
07:42:55-568796 INFO     Setting Torch parameters: dtype=torch.float16 vae=torch.float16 unet=torch.float16
LatentDiffusion: Running in eps-prediction mode
DiffusionWrapper has 859.52 M params.
Downloading (…)olve/main/vocab.json: 100%|████████████████████████████████████████████| 961k/961k [00:01<00:00, 848kB/s]
Downloading (…)olve/main/merges.txt: 100%|███████████████████████████████████████████| 525k/525k [00:00<00:00, 1.27MB/s]
Downloading (…)cial_tokens_map.json: 100%|██████████████████████████████████████████████| 389/389 [00:00<00:00, 347kB/s]
Downloading (…)okenizer_config.json: 100%|█████████████████████████████████████████████| 905/905 [00:00<00:00, 4.47MB/s]
Downloading (…)lve/main/config.json: 100%|█████████████████████████████████████████| 4.52k/4.52k [00:00<00:00, 1.60MB/s]
Calculating model hash: /sd-webui/models/Stable-diffusion/v1-5-pruned-emaonly.safetensors ━━━━━━━━━━━ 4.3/4.3 GB 0:00:00
07:43:25-547549 INFO     Applying sub-quadratic cross attention optimization
07:43:25-718775 INFO     Applied IPEX Optimize
07:43:26-115071 INFO     Embeddings: loaded=0 skipped=0
07:43:26-119315 INFO     Model loaded in 32.1s (load=0.9s config=0.6s create=5.1s hash=7.7s apply=16.2s vae=0.2s
                         move=0.8s embeddings=0.6s)
07:43:26-235786 INFO     Model load finished: {'ram': {'used': 7.73, 'total': 23.47}, 'gpu': {'used': 2.02, 'total':
                         12.7}, 'retries': 0, 'oom': 0} cached=0
07:43:26-415000 INFO     Startup time: 46.2s (torch=1.3s gradio=0.9s libraries=2.4s vae=0.1s codeformer=0.6s
                         scripts=4.3s onchange=1.0s ui=2.5s launch=0.2s app-started=0.2s checkpoint=32.6s)
```

<!-- tabs:end -->

## 在宿主机上访问SD.Next目录

还记得之前`docker run`命令中指定的`-v <host_mount_dir>:/sd-webui`选项吧？`<host_mount_dir>`就是宿主机上的一个目录，且与容器内的`/sd-webui`目录保持同步。

你可以在宿主机上修改`<host_mount_dir>`（默认：`$home\docker-mount\sd-webui`）目录的内容，所有改动都会实时反映到容器中。

比如，你可以将SD模型复制到`<host_mount_dir>\models\Stable-diffusion`，在`<host_mount_dir>\outputs`目录中查看生成的图片，甚至是直接在宿主机上执行`git`相关操作。

## 管理SD.Next容器

### 终止容器

几个方法：

- 在可交互命令行中按`Ctrl + C`。
- 直接关掉可交互命令行。
- 打开Docker Desktop面板，点击`Containers（容器）`标签找到正在运行的容器（比如名为`sd-server`）。点击停止:black_medium_square:按钮。
- 退出Docker Desktop。

### 重启容器

关掉容器之后，有几种方法可以重启它：

- 打开Docker Desktop面板，点击`Containers（容器）`标签找到你想运行的容器（比如名为`sd-server`）。点击启动按钮。这不会帮你打开一个可交互的命令行界面，但你可以通过点击容器名字然后进入`Logs（日志）`标签查看日志。
- 在宿主机上打开一个终端（比如PowerShell或者bash），执行`docker start -i <container_name>`。

### 用不同Web UI参数启动容器

需要创建一个新容器来实现这个操作。只要你给新容器指定的`<host_mount_dir>`和数据卷`<volume_name>`和之前的容器相同，那新容器就可以复用Web UI目录和pyton虚拟环境，这种情况下新开一个容器的开销小到可以忽略。

直接将你定制的Web UI参数加在**镜像名字之后**（比如给新容器加上`--debug --lowvram --no-half`参数）：

<!-- tabs:start -->

#### **Windows**

```powershell
docker run -it `
--device /dev/dxg `
-v /usr/lib/wsl:/usr/lib/wsl `
-v $home\docker-mount\sd-webui:/sd-webui `
-v deps:/deps `
-p 7860:7860 `
--name customized-sd-server `
nuullll/ipex-arc-sd:latest `
--debug --lowvram --no-half
```

#### **Linux**

```bash
docker run -it \
--device /dev/dri \
-v ~/docker-mount/sd-webui:/sd-webui \
-v deps:/deps \
-p 7860:7860 \
--name customized-sd-server \
nuullll/ipex-arc-sd:latest \
--debug --lowvram --no-half
```

<!-- tabs:end -->

如果你打算长期使用这个新容器，你可以像上面一样给它指定一个新名字。如果你只是在调试或者做一些临时实验，那你可以把`--name customized-sd-server`替换成`--rm`，来让docker在这个容器时退出时自动删除它。

### 更新SD.Next源代码

我们可以用上面的技巧（通过指定`--upgrade`选项）来更新[SD.Next](https://github.com/vladmandic/automatic)的代码来体验最新的功能：

<!-- tabs:start -->

#### **Windows**

```powershell
docker run -it `
--device /dev/dxg `
-v /usr/lib/wsl:/usr/lib/wsl `
-v $home\docker-mount\sd-webui:/sd-webui `
-v deps:/deps `
-p 7860:7860 `
--rm `
nuullll/ipex-arc-sd:latest --upgrade
```

#### **Linux**

```bash
docker run -it \
--device /dev/dri \
-v ~/docker-mount/sd-webui:/sd-webui \
-v deps:/deps \
-p 7860:7860 \
--rm \
nuullll/ipex-arc-sd:latest --upgrade
```

<!-- tabs:end -->

这里使用`--rm`很合理，因为我们实际上是在更新`<host_mount_dir>`目录的内容，它的改动会自动反映到我们原来的容器中。

### 在正在运行的容器中新开一个终端

有时我们可能想在不关掉正在运行的容器的前提下，查看一下它的状态。

你可以在宿主机上打开终端，执行

```powershell/bash
docker exec -i <container_name> bash
```

或者打开Docker Desktop面板前往`Containers（容器）`页面，找到你的容器点击名字，最后点击`Terminal（终端）`标签。

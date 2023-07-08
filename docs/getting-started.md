# Getting Started

For Chinese users, there's also a [tutorial video](https://www.bilibili.com/video/BV1Ek4y1u7Z4/) posted on Bilibili.

## Requirements

* Install [Docker Desktop](https://www.docker.com/) on your system.
  - If you are using Windows, be sure to use the WSL 2 based docker engine, which is the default setting. You can go to `Setting -> General` in Docker Desktop GUI to examine whether the `Use the WSL 2 based engine` option is checked.
* Healthy network connections. :surfer:

## Launch the docker container with the remote image

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

In case you are not familiar with docker, let's see what is going on with this long magical command:

- [`docker run`](https://docs.docker.com/engine/reference/commandline/run/) creates and runs **a new container** from an image.
- The last argument `nuullll/ipex-arc-sd:latest` specifies the image, in format of `<image_name>:<tag>`. If the image doesn't exist on your local machine, docker will try to pull from [DockerHub remote registry](https://hub.docker.com/r/nuullll/ipex-arc-sd).
- `--name sd-server` assigns a meaningful name (e.g. `sd-server`) to the newly created container. This option is useful but not mandatory.
- `-it` will let you launch the container with an interactive command line. This is highly recommended since we may need to monitor the Web UI status via the command line log output.
- On linux, `--device /dev/dri` is required to enable container access to your GPUs. On windows, `--device /dev/dxg` and `-v /usr/lib/wsl:/usr/lib/wsl` are both required to enable container access to your GPUs. See [wslg samples](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md#containerized-applications-access-to-the-vgpu) for details.
- `-v <host_mount_dir>:/sd-webui` specifies a directory on host to be [bind-mounted](https://docs.docker.com/storage/bind-mounts/) to `/sd-webui` directory inside the container. When you launch the container for the first time, you should specify an **empty or non-existent** directory on host as `<host_mount_dir>`, so that the container can pull [SD.Next](https://github.com/vladmandic/automatic) source code into the corresponding directory. If you want to launch another container (e.g. [overriding the docker entrypoint](https://docs.docker.com/engine/reference/run/#entrypoint-default-command-to-execute-at-runtime)) that shares the initialized Web UI folder, you should specify the same `<host_mount_dir>`.
- `-v <volume_name>:/deps` specifies a [volume](https://docs.docker.com/storage/volumes/) managed by the docker engine (e.g. a volume named as `deps`), to be mounted as `/deps` directory inside the container. `/deps` is configured as the python virtual environment root directory (see [`Dockerfile: ENV venv_dir`](https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/blob/main/Dockerfile)), to store all dynamic python dependencies (e.g. packages needed by Web UI extensions) required after the Web UI launches. You can mount the `deps` volume to multiple containers so that those dynamic dependencies would be downloaded and installed only once. This is useful for users who want to run containers with different Web UI arguments (e.g. `--debug`), and for those who actually build local docker images.
- `-p <host_port>:7860` specifies the [published port](https://docs.docker.com/network/). The Web UI running on 7860 port inside the container will be forwarded to `http://localhost:<host_port>` on your host system.

### Expected result

<!-- tabs:start -->

#### **Pulling the image from DockerHub**

This may take some time, but it's a one-time setup unless you want to upgrade the image to a newer version. Take a coffee break!

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

You will see the following upon success:

```txt
Status: Downloaded newer image for nuullll/ipex-arc-sd:latest
```

#### **Cloning [SD.Next](https://github.com/vladmandic/automatic) source code**

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

You may notice the fatal error on the first line: `fatal: not a git repository`. Don't worry, it's expected since we are bind-mounting an empty or non-existent host directory as the Web UI source code folder for the first time. The script will clone [SD.Next](https://github.com/vladmandic/automatic) into that folder.

#### **Launching Web UI server**

The Web UI will try to install python dependencies for the first time.

All the python packages will be installed into the docker volume `deps` (as specified by the `-v deps:/deps` option) and the data is **persistent**. So each dependency will be downloaded and installed only once, unless you manually remove the `deps` volume or mount a new volume to the container.

```txt
Create and activate python venv
Launching launch.py...
06:37:21-673336 INFO     Starting SD.Next
06:37:21-679480 INFO     Python 3.10.6 on Linux
06:37:21-762667 INFO     Version: 205b5164 Fri Jul 7 22:41:26 2023 +0300
06:37:21-822410 INFO     Intel OneAPI Toolkit detected   <<<<<------------ oneAPI environment baked in the image is detected!
06:37:21-825165 INFO     Installing package: torch==1.13.0a0 torchvision==0.14.1a0
                         intel_extension_for_pytorch==1.13.120+xpu -f https://developer.intel.com/ipex-whl-stable-xpu   <<<<<------------ installing torch and ipex for Intel XPU!
06:39:59-352248 INFO     Torch 1.13.0a0+gitb1dde16
/deps/venv/lib/python3.10/site-packages/torchvision/io/image.py:13: UserWarning: Failed to load image Python extension:
  warn(f"Failed to load image Python extension: {e}")   <<<<<------------ Warning is a warning
06:39:59-901569 INFO     Torch backend: Intel IPEX 1.13.120+xpu   <<<<<------------ IPEX XPU backend is used
/bin/sh: 1: icpx: not found   <<<<<------------ Don't worry. This is harmless
06:39:59-905688 INFO
06:39:59-908720 INFO     Torch detected GPU: Intel(R) Graphics [0x56a0] VRAM 13005 Compute Units 512   <<<<<------------ your Arc GPU is detected! (0x56a0 is the device ID for Arc A770)
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

#### **Downloading the default model**

```txt
Download the default model? (y/N)
```

When you see this prompt, input `y` if you need the default model.

Or just copy your favorite models into `$home\docker-mount\sd-webui\models\Stable-diffusion`. Note `$home\docker-mount\sd-webui` is the `<host_mount_dir>` specified with `-v <host_mount_dir>:/sd-webui`.

#### **All set!**

Now open the Web UI in your favorite browser on the host!

[http://localhost:7860/](http://localhost:7860/)

Enjor your Stable Diffusion journey! :fire:

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

## Access your SD.Next directory on the host machine

Remeber the `-v <host_mount_dir>:/sd-webui` option of the previous `docker run` command? `<host_mount_dir>` is a host directory that is synced with the `/sd-webui` directory inside the container.

You can edit the content of `<host_mount_dir>` (default: `$home\docker-mount\sd-webui`) from the host and all changes will be reflected inside the container in real time.

For example, you can copy your SD models into `<host_mount_dir>\models\Stable-diffusion`, check generated images in `<host_mount_dir>\outputs`, or even perform `git` operations from the host.

## Manage your SD.Next containers

### Stop container

Several ways:

- Press `Ctrl + C` in the interactive command line.
- Close the interactive command line directly.
- Open Docker Desktop Dashboard, then go to the `Containers` tab and find your running container (e.g. named as `sd-server`) in the list. Click the "stop" :black_medium_square: button.
- Quit Docker Desktop.

### Restart container

After you stop the container, there're also several ways to restart it:

- Open Docker Desktop Dashboard, then go to the `Containers` tab and find your container in the list. Click the "start" button. This will not open an interactive command line for you, but you can check logs by clicking the name of the container and go to the `Logs` tab.
- Open a terminal on your host (e.g. PowerShell or bash) and execute `docker start -i <container_name>`.

### Launch your container with different Web UI arguments

You need to create a new container to achieve this. As long as you specify the same `<host_mount_dir>` and `<volume_name>` for the new container, the Web UI folder and python virtual environment will be reused, and in this case, the overhead of creating a new container is little to none.

Just append your customized Web UI arguments **after the image name** (we are adding the `--debug --lowvram --no-half` options to the new container):

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

You can give a different name to the new container as above, if you plan to use this container in the long run. If you are just debugging or doing some temporary experiments, you could replace `--name customized-sd-server` with `--rm` to tell docker to remove this container when it exits.

### Upgrade SD.Next source code

We could use the technique above to upgrade the [SD.Next](https://github.com/vladmandic/automatic) source code to get the latest features (by specifying the `--upgrade` option):

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

It makes sense to use `--rm` here, because we are actually updating the content of the `<host_mount_dir>`, whose changes will be reflected to our original container automatically.

### Open another terminal for a running container

Sometimes you may want to check the status of a running container without stopping it.

You could either open a terminal on host and execute

```powershell/bash
docker exec -i <container_name> bash
```

or open Docker Desktop Dashboard, then go to the `Containers` tab, find your container and click the name, and finally go to the `Terminal` tab.

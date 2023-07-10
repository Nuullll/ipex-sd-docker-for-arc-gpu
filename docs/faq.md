# Frequently Asked Questions

## Environment setup

### Network issues when cloning from Github

![](/assets/github-connection-443.jpg)

> Network issues are common for Chinese users...
>
> Please setup a stable proxy on your host, enable [TUN mode](https://docs.cfw.lbyczf.com/contents/tun.html) (and probably a combination with `System Proxy`) and retry.
>
> Or you can specify proxy enironment variables when executing `docker run`:
> 
> ```powershell
> docker run -it `
> --device /dev/dxg `
> -v /usr/lib/wsl:/usr/lib/wsl `
> -v $home\docker-mount\sd-webui:/sd-webui `
> -v deps:/deps `
> -v huggingface:/root/.cache/huggingface `
> -p 7860:7860 `
> --rm `
> -e http_proxy=<host_ip>:<proxy_port> `
> -e https_proxy=<host_ip>:<proxy_port> `
> nuullll/ipex-arc-sd:latest
> ```
> 
> For example, `-e http_proxy=http://192.168.1.2:7890`. `localhost` or `127.0.0.1` might not work for WSL2, please use your real host IP as the `<host_ip>`.

### Network issues when installing python packages

> Network issues are common for Chinese users... You can always try the methods mentioned [above](#network-issues-when-cloning-from-github).
>
> Or you can specify a Chinese mirror (e.g. THU TUNA) for pip via the environment variable `PIP_EXTRA_INDEX_URL`:
>
> ```powershell
> docker run -it `
> --device /dev/dxg `
> -v /usr/lib/wsl:/usr/lib/wsl `
> -v $home\docker-mount\sd-webui:/sd-webui `
> -v deps:/deps `
> -v huggingface:/root/.cache/huggingface `
> -p 7860:7860 `
> --rm `
> -e PIP_EXTRA_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple `
> nuullll/ipex-arc-sd:latest
> ```

### docker run: Ports are not available

![](/assets/port-not-available.png)

Full error:

```txt
docker: Error response from daemon: Ports are not available: exposing port TCP 0.0.0.0:7860 -> 0.0.0.0: listen tcp 0.0.0.0:7860: bind: An attempt was made to access a socket in a way forbidden by its access permissions.
```

> This happened to me (on Windows) under certain network configurations.
>
> Solution ([reference](https://github.com/docker/for-win/issues/9272#issuecomment-776225866)):
> 1. Open a cmd/powershell as **administrator**.
> 2. Execute `net stop winnat`.
> 3. [Restart your container](getting-started.md#restart-container).
> 4. Execute `net start winnat` after the container is up.

### Killed without further information

![](/assets/killed.jpg)

> Caused by insufficient memory allocated to WSL. The Web UI requires a minimum of 7GB memory (estimated) for basic functionalities.
>
> By default, 50% of host system memory will be allocated to WSL. You can [execute `free -m` inside container](getting-started.md#open-another-terminal-for-a-running-container) to check.
>
> Solution ([reference](https://learn.microsoft.com/en-us/answers/questions/1296124/how-to-increase-memory-and-cpu-limits-for-wsl2-win)):
> 1. Create a text file named as `.wslconfig` under your host home directory.
> 2. Edit and save `.wslconfig` as following (16GB for example):
> 
> ```.wslconfig
> # Settings apply across all Linux distros running on WSL 2
> [wsl2]
> 
> # Limits VM memory to use no more than 16 GB, this can be set as whole numbers using GB or MB
> memory=16GB
> ```

## Web UI running

### Container hanging

> You may not be able to [stop the container](getting-started.md#stop-container) in normal ways.
>
> Try to right-click the Docker Desktop icon in the system tray and click `restart`. Otherwise, reboot your computer. :cold_sweat:

### URLError: [Errno 99] Cannot assign requested address

![](/assets/urlerror.png)

> This may happen while generating images and the frontend is submitting too many progress querying requests, but the error does not have any impact on generated images.
>
> Solution:
>
> Edit `<host_mount_dir>\javascript\progressBar.js`: change the default value of `once` to `true` for function `requestProgress()`.

### Aborted while generating images

Full error:

```txt
Abort was called at 718 line in file:
../../neo/shared/source/os_interface/windows/wddm_memory_manager.cpp
```

> Solution: disable your iGPU in the device manager or BIOS. See [#1272](https://github.com/vladmandic/automatic/issues/1272).

### DPCPP out of memory after a few generations

Full error:

```txt
DPCPP out of memory. Tried to allocate 186.00 MiB (GPU Time taken: 22.18s | GPU active 3754 MB reserved 3888 MB | System peak 3754 MB total 13005 MB
```

> See [#8](https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/issues/8). I've reproduced the issue, but unfortunately root cause is unclear. It seems like a memory leak issue.
>
> Solution: restart the Web UI server.


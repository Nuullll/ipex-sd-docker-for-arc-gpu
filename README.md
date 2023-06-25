# docker-sd-webui-ipex
Docker for Intel Arc GPU: Intel Pytorch EXtension + SD.Next

The Stable Diffusion Web UI variant used by the image: [vladmandic/automatic](https://github.com/vladmandic/automatic)

### Run docker container on Linux

Run container, with image pulled from https://hub.docker.com/r/nuullll/ipex-arc-sd

```sh
docker run -it \
--device /dev/dri \
-v ~/docker-mount/sd-webui:/sd-webui \
-v deps:/deps \
-p 7860:7860 \
--name sd-server \
disty0/sd-webui-ipex:latest
```

### Run docker container in PowerShell on Windows

Run container, with image pulled from https://hub.docker.com/r/nuullll/ipex-arc-sd

```powershell
docker run -it `
--device /dev/dxg `
-v /usr/lib/wsl:/usr/lib/wsl `
-v $home\docker-mount\sd-webui:/sd-webui `
-v deps:/deps `
-p 7860:7860 `
--name sd-server `
nuullll/ipex-arc-sd:v0.1
```

### Parameters

1. `-it` to see logging output interactively
2. `--device /dev/dri` on Linux or `--device /dev/dxg` and `-v /usr/lib/wsl:/usr/lib/wsl` on Windows are required to enable container GPU access. See [wslg samples](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md#containerized-applications-access-to-the-vgpu) for details.
3. `-v <host_mount_dir>:/sd-webui` specifies a directory on host to be [bind-mounted](https://docs.docker.com/storage/bind-mounts/) to `/sd-webui` directory inside the container. When you launch the container for the first time, you should specify an empty or non-existent directory on host as `<host_mount_dir>`, so that the container can pull [vladmandic/automatic](https://github.com/vladmandic/automatic) source code into the corresponding directory. If you want to launch another container (e.g. [overriding the docker entrypoint](https://docs.docker.com/engine/reference/run/#entrypoint-default-command-to-execute-at-runtime)) that shares the initialized Web UI folder, you should specify the same `<host_mount_dir>`.
4. `-v deps:/deps` specifies a [volume](https://docs.docker.com/storage/volumes/) managed by the docker engine, named as `deps` (just choose any name you like), to be mounted as `/deps` directory inside the container. `/deps` is configured (see `./startup.sh`) to store all dynamic python dependencies (e.g. packages needed by Web UI extensions) required after the Web UI launches. You can mount the `deps` volume to multiple containers so that those dynamic dependencies would be downloaded and installed only once. This is useful for users who want to run containers with different Web UI arguments (e.g. `--debug`), and for those who actually build local docker images.
5. `-p 7860:7860` specifies the [published port](https://docs.docker.com/network/).
6. `--name <container_name>` assigns the container a meaningful name. You can restart the same container (after it exits) by `docker start -i <container_name>`.
7. `nuullll/ipex-arc-sd:v0.1` specifies the docker image. If it doesn't exist locally, docker will pull from the [corresponding dockerhub registry](https://hub.docker.com/r/nuullll/ipex-arc-sd).

### (For Developers) Build docker image 

### In Linux

```sh
docker build --build-arg UBUNTU_VERSION=22.04 \
--build-arg PYTHON=python3.10 \
--build-arg ICD_VER=23.17.26241.21-647~22.04 \
--build-arg LEVEL_ZERO_GPU_VER=1.3.26241.21-647~22.04 \
--build-arg LEVEL_ZERO_VER=1.11.0-647~22.04 \
--build-arg LEVEL_ZERO_DEV_VER=1.11.0-647~22.04 \
--build-arg DPCPP_VER=2023.1.0-46305 \
--build-arg MKL_VER=2023.1.0-46342 \
--build-arg CMPLR_COMMON_VER=2023.1.0 \
--build-arg DEVICE=flex \
-t sd-webui-ipex \
-f Dockerfile .
```

### In PowerShell on Windows

```powershell
docker build --build-arg UBUNTU_VERSION=22.04 `
--build-arg PYTHON=python3.10 `
--build-arg ICD_VER=23.17.26241.21-647~22.04 `
--build-arg LEVEL_ZERO_GPU_VER=1.3.26241.21-647~22.04 `
--build-arg LEVEL_ZERO_VER=1.11.0-647~22.04 `
--build-arg LEVEL_ZERO_DEV_VER=1.11.0-647~22.04 `
--build-arg DPCPP_VER=2023.1.0-46305 `
--build-arg MKL_VER=2023.1.0-46342 `
--build-arg CMPLR_COMMON_VER=2023.1.0 `
--build-arg DEVICE=flex `
-t sd-webui-ipex `
-f Dockerfile .
```

**Notes: `ICD_VER=23.05.25593.18-601~22.04` is used by the [IPEX xpu Dockerfile](https://github.com/intel/intel-extension-for-pytorch/blob/e413ea5f4501ed9bfc9ff4040b46ff4ce8fca87a/docker/build.sh#L34), which triggers an [OpenCL Out-Of-Memory error](https://github.com/vladmandic/automatic/issues/1474) for me.**
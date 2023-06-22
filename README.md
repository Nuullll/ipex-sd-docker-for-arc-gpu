# ipex-sd-docker-for-arc-gpu
Docker for Intel Arc GPU: Intel Pytorch EXtension + Stable Diffusion web ui

The SD Web UI variant used by the image: [vladmandic/automatic](https://github.com/vladmandic/automatic)

### Run docker container in PowerShell

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
2. `--device /dev/dxg` and `-v /usr/lib/wsl:/usr/lib/wsl` are required to enable container GPU access. See [wslg samples](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md#containerized-applications-access-to-the-vgpu) for details.
3. `-v <host_mount_dir>:/sd-webui` specifies a directory on host to be [bind-mounted](https://docs.docker.com/storage/bind-mounts/) to `/sd-webui` directory inside the container. When you launch the container for the first time, you should specify an empty or non-existent directory on host as `<host_mount_dir>`, so that the container can pull [vladmandic/automatic](https://github.com/vladmandic/automatic) source code into the corresponding directory. If you want to launch another container (e.g. [overriding the docker entrypoint](https://docs.docker.com/engine/reference/run/#entrypoint-default-command-to-execute-at-runtime)) that shares the initialized Web UI folder, you should specify the same `<host_mount_dir>`.
4. `-v deps:/deps` specifies a [volume](https://docs.docker.com/storage/volumes/) managed by the docker engine, named as `deps` (just choose any name you like), to be mounted as `/deps` directory inside the container. `/deps` is configured (see `./startup.sh`) to store all dynamic python dependencies (e.g. packages needed by Web UI extensions) required after the Web UI launches. You can mount the `deps` volume to multiple containers so that those dynamic dependencies would be downloaded and installed only once. This is useful for users who want to run containers with different Web UI arguments (e.g. `--debug`), and for those who actually build local docker images.
5. `-p 7860:7860` specifies the [published port](https://docs.docker.com/network/).
6. `--name <container_name>` assigns the container a meaningful name. You can restart the same container (after it exits) by `docker start -i <container_name>`.
7. `nuullll/ipex-arc-sd:v0.1` specifies the docker image. If it doesn't exist locally, docker will pull from the [corresponding dockerhub registry](https://hub.docker.com/r/nuullll/ipex-arc-sd).

### (For Developers) Build docker image in PowerShell

```powershell
docker build --build-arg UBUNTU_VERSION=22.04 `
--build-arg PYTHON=python3.10 `
--build-arg ICD_VER=23.17.26241.21-647~22.04 `
--build-arg LEVEL_ZERO_GPU_VER=1.3.25593.18-601~22.04 `
--build-arg LEVEL_ZERO_VER=1.9.4+i589~22.04 `
--build-arg LEVEL_ZERO_DEV_VER=1.9.4+i589~22.04 `
--build-arg DPCPP_VER=2023.1.0-46305 `
--build-arg MKL_VER=2023.1.0-46342 `
--build-arg CMPLR_COMMON_VER=2023.1.0 `
--build-arg TORCH_VERSION=1.13.0a0+git6c9b55e `
--build-arg IPEX_VERSION=1.13.120+xpu `
--build-arg TORCHVISION_VERSION=0.14.1a0+5e8e2f1 `
--build-arg IPEX_WHL_URL=https://developer.intel.com/ipex-whl-stable-xpu `
--build-arg DEVICE=flex `
-t ipex-arc-sd:v0.1 `
-f Dockerfile .
```

**Notes: `ICD_VER=23.05.25593.18-601~22.04` is used by the [IPEX xpu Dockerfile](https://github.com/intel/intel-extension-for-pytorch/blob/e413ea5f4501ed9bfc9ff4040b46ff4ce8fca87a/docker/build.sh#L34), which triggers an [OpenCL Out-Of-Memory error](https://github.com/vladmandic/automatic/issues/1474) for me.**

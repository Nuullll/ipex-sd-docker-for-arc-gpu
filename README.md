# ipex-sd-docker-for-arc-gpu
Docker for Intel Arc GPU: Intel Pytorch EXtension + Stable Diffusion web ui

## [vladmandic/automatic](https://github.com/vladmandic/automatic)

### Run docker container in PowerShell

Run container with `-it`, pulled from https://hub.docker.com/r/nuullll/ipex-arc-sd

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

Rerun container by its name

```powershell
docker start -i sd-server
```

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

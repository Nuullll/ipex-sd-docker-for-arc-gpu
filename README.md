# Stable Diffusion Web UI Docker for Intel Arc GPUs

<a href="https://hub.docker.com/r/nuullll/ipex-arc-sd">
  <img src="https://img.shields.io/docker/pulls/nuullll/ipex-arc-sd" />
</a>

- [Documentation](https://blog.nuullll.com/ipex-sd-docker-for-arc-gpu/#/)
- [Getting Started](https://blog.nuullll.com/ipex-sd-docker-for-arc-gpu/#/getting-started)
- [FAQ](https://blog.nuullll.com/ipex-sd-docker-for-arc-gpu/#/faq)
- [Release Notes](https://blog.nuullll.com/ipex-sd-docker-for-arc-gpu/#/release-notes)

The [docker image](https://hub.docker.com/r/nuullll/ipex-arc-sd) includes
- Intel oneAPI DPC++ runtime libs _(Note: compiler executables are not included)_
- Intel oneAPI MKL runtime libs
- Intel oneAPI compiler common tool `sycl-ls`
- Intel Graphics driver
- Basic python environment

The Stable Diffusion Web UI variant used by the image: [SD.Next](https://github.com/vladmandic/automatic)

- Intel Extension for Pytorch (IPEX) and other python packages will be installed by [SD.Next](https://github.com/vladmandic/automatic) dynamically

## (For Developers) Build docker image locally

```powershell
docker build -t ipex-arc-sd -f Dockerfile .
```

Refer to [Dockerfile](./Dockerfile) for available build arguments.

## Contributors

<a href="https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Nuullll/ipex-sd-docker-for-arc-gpu" />
</a>

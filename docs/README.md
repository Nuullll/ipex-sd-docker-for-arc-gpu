# Stable Diffusion Web UI Docker for Arc GPUs

> Let's release the AI power of Intel Arc GPUs :fire:

## What it is

A docker project to containerize all environment requirements to enable Stable Diffusion workloads for **Intel Arc GPUs**.

You can use your Arc GPUs for fancy image generations with minimal setup! Start now: [Getting started](/getting-started)

## Docker Image Release

<a href="https://hub.docker.com/r/nuullll/ipex-arc-sd" target="_blank">
  <img src="https://img.shields.io/docker/pulls/nuullll/ipex-arc-sd?label=DockerHub:nuullll%2Fipex-arc-sd" />
</a>

## Stable Diffusion Web UI

Stable Diffusion Web UI variant used by the image: [SD.Next](https://github.com/vladmandic/automatic) (A.K.A, vladmandic/automatic).

_Note: [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) doesn't support Arc GPUs, see [#4690](https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/4690), [#6417](https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/6417)._

## How SD.Next works on Arc GPUs

Given that [SD.Next](https://github.com/vladmandic/automatic) is using PyTorch as the AI framework for Stable Diffusion applications, [Intel Extension for PyTorch (IPEX)](https://github.com/intel/intel-extension-for-pytorch) provides easy GPU acceleration for Intel discrete GPUs with PyTorch. And fortunately, IPEX provides [experimental support](https://intel.github.io/intel-extension-for-pytorch/xpu/latest/tutorials/installation.html) for **Intel Arc A-Series GPUs**!

Minor code changes are required to actually enable AI workloads with IPEX's XPU backend, which have been implemented by contributors of [SD.Next](https://github.com/vladmandic/automatic). And [SD.Next](https://github.com/vladmandic/automatic) will also try to install the corresponding IPEX dependencies by default.

IPEX itself also has dependencies on [Intel GPU Driver](https://dgpu-docs.intel.com/installation-guides/index.html) and [oneAPI base Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html). Installing them manually could be time-consuming and error-prone for users (it's not easy to install all required packages with **proper** versions).

**Don't worry, the [docker image](https://hub.docker.com/r/nuullll/ipex-arc-sd) will handle all the complexities for you. :hearts:**

## Community

- [Github Discussion](https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/discussions)
- :penguin: Group ID: 558[zero]74047

## Contributors

<a href="https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Nuullll/ipex-sd-docker-for-arc-gpu" />
</a>

# Stable Diffusion Web UI Docker for Arc GPUs

> 一起释放英特尔锐炫显卡的AI能量 :fire:

## 这是什么

一个docker项目，将**英特尔锐炫显卡**运行Stable Diffusion应用所需要的所有环境需求进行容器化。

只需要超简单的配置，你就可以使用锐炫显卡生成超酷的图片！现在开始：[开始使用](/zh-cn/getting-started)

## Docker镜像发布

<a href="https://hub.docker.com/r/nuullll/ipex-arc-sd" target="_blank">
  <img src="https://img.shields.io/docker/pulls/nuullll/ipex-arc-sd?label=DockerHub:nuullll%2Fipex-arc-sd" />
</a>

## Stable Diffusion Web UI

此镜像使用的Stable Diffusion Web UI版本为：[SD.Next](https://github.com/vladmandic/automatic) (或者叫 vladmandic/automatic).

_注：[AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui)不支持锐炫显卡，详见[#4690](https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/4690)，[#6417](https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/6417)。_

## SD.Next是如何支持锐炫显卡的

由于[SD.Next](https://github.com/vladmandic/automatic)使用AI框架PyTorch运行Stable Diffusion应用，而[英特尔PyTorch扩展 (IPEX)](https://github.com/intel/intel-extension-for-pytorch)提供了针对英特尔独立显卡的PyTorch加速。幸运的是，IPEX对**英特尔锐炫A系列显卡**也提供了[实验性支持](https://intel.github.io/intel-extension-for-pytorch/xpu/latest/tutorials/installation.html)！

要在IPEX的XPU后端上运行AI应用，需要对应用代码做一些小的改动，这些工作[SD.Next](https://github.com/vladmandic/automatic)的贡献者们已经搞定。[SD.Next](https://github.com/vladmandic/automatic)默认也会尝试安装IPEX。

IPEX本身还对英特尔显卡驱动以及oneAPI基础套件有依赖。手动安装这些依赖项不仅费时，还容易出错（很难将所有需要的软件包安装为**正确的**版本）。

**别担心，[这个docker镜像](https://hub.docker.com/r/nuullll/ipex-arc-sd)会帮你搞定这些复杂的问题。:hearts:**

## 社群

- [Github讨论区](https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/discussions)
- :penguin: 群：558[零]74047

## 贡献者

<a href="https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Nuullll/ipex-sd-docker-for-arc-gpu" />
</a>

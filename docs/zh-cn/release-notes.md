# 更新日志

## [v0.3](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.3/images/sha256-accb961e63a14b92567e7c594ad5222fd4592a40b8e3c5a76310a70257b1f00e?context=explore) （最新）

压缩后镜像大小：831.25 MB

重要通知：

* IPEX在WSL2中存在严重的显存泄漏问题（https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/issues/8, https://github.com/intel/intel-extension-for-pytorch/issues/388），现已在SD.Next https://github.com/vladmandic/automatic/commit/c3a4293f2227fe77b9ea908c99a1bda2aef43175 中临时解决。**如果你使用的是WSL，请根据[这里的指示](https://blog.nuullll.com/ipex-sd-docker-for-arc-gpu/#/getting-started?id=upgrade-sdnext-source-code)将SD.Next代码更新。**

主要变动：

* 使用TCMalloc来缓解WSL中的内存泄漏问题。
* 挂载`/root/.cache/huggingface`数据卷，避免重复下载huggingface模型。

镜像（基于Ubuntu 22.04）中包含：

- Intel oneAPI DPC++运行时库 (2023.1) （注：不包含编译器可执行文件）
- Intel oneAPI MKL运行时库 (2023.1)
- Intel oneAPI 编译器通用工具sycl-ls (2023.1)
- Intel显卡驱动(1.3.26241.21-647~22.04)
- 基础python环境 (3.10.6)

在Windows 11 22H2 22621.1848 + i9-13900 + Arc A770 (Windows driver: 31.0.101.4502)环境下测试通过。

## [v0.2](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.2/images/sha256-58f7c7ae5b837b427623472a23582c1b4ecbd49460d245ddcb533e721cb396db?context=explore)

压缩后镜像大小：827.1 MB

主要变动：
- 将IPEX和SD.Next所需要的python包从镜像中移除来减小镜像大小。
- 将除了sycl-ls之外没用的编译器工具移除来减小镜像大小。
- 将Intel显卡驱动版本升级为1.3.26241.21-647~22.04。

镜像（基于Ubuntu 22.04）中包含：

- Intel oneAPI DPC++运行时库 (2023.1) （注：不包含编译器可执行文件）
- Intel oneAPI MKL运行时库 (2023.1)
- Intel oneAPI 编译器通用工具sycl-ls (2023.1)
- Intel显卡驱动(1.3.26241.21-647~22.04)
- 基础python环境 (3.10.6)

在Windows 11 22H2 22621.1848 + i9-13900 + Arc A770 (Windows driver: 31.0.101.4382)环境下测试通过。

## [v0.1](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.1/images/sha256-5c00e46920a396a2b1c69e5ad24218883ba205afe6d59ce153f12f684ef2c006)

压缩后镜像大小：2.11 GB

初版。镜像（基于Ubuntu 22.04）中包含：

- Intel oneAPI DPC++运行时库 (2023.1) （注：不包含编译器可执行文件）
- Intel oneAPI MKL运行时库 (2023.1)
- Intel oneAPI 编译器通用工具sycl-ls (2023.1)
- Intel显卡驱动 (1.3.25593.18-601~22.04)
- 基础python环境 (3.10.6)
- IPEX (1.13.120+xpu)以及SD.Next requirements.txt指定的python包

在Windows 11 22H2 22621.1848 + i9-13900 + Arc A770 (Windows driver: 31.0.101.4382)环境下测试通过。

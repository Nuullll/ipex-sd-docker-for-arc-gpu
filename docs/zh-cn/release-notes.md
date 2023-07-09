# 更新日志

## [v0.2](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.2/images/sha256-58f7c7ae5b837b427623472a23582c1b4ecbd49460d245ddcb533e721cb396db?context=explore) （最新）

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

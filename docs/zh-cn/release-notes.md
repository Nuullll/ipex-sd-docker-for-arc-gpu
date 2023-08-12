# 更新日志

## [v0.6](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.6/images/sha256-30bdf186bc21abbcbb1d59ee87b4a726af9aa93794543121caf58ba95f44caaa?context=explore) (最新)

压缩后镜像大小：845.44 MB

主要变动：

- oneAPI版本升级至2023.2，支持IPEX XPU 2.0

镜像（基于Ubuntu 22.04）中包含：

- Intel oneAPI DPC++运行时库 (2023.2.1) （注：不包含编译器可执行文件）
- Intel oneAPI MKL运行时库 (2023.2.0)
- Intel oneAPI 编译器通用工具sycl-ls (2023.2.1)
- Intel显卡驱动 (1.3.26241.33-647~22.04)
- 基础python环境 (3.10.6)

在Windows 11 22H2 22621.1848 + i9-13900 + Arc A770 (Windows driver: 31.0.101.4502)环境下测试通过。

## [v0.5](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.5/images/sha256-bb556a04a3ad6d331582ad1d64e79a123650fd43981d2bdd3c2e1f639bde818c?context=explore)

压缩后镜像大小：831.44 MB

Major changes:

- Allow extension installation by default (`--insecure`)
- Skip startup git operations by default (`--skip-git`)
- Use faster offline git repo check

镜像（基于Ubuntu 22.04）中包含：

- Intel oneAPI DPC++运行时库 (2023.1) （注：不包含编译器可执行文件）
- Intel oneAPI MKL运行时库 (2023.1)
- Intel oneAPI 编译器通用工具sycl-ls (2023.1)
- Intel显卡驱动 (1.3.26241.21-647~22.04)
- 基础python环境 (3.10.6)

在Windows 11 22H2 22621.1848 + i9-13900 + Arc A770 (Windows driver: 31.0.101.4502)环境下测试通过。

## [v0.4](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.4/images/sha256-ca5ba4aab952e6afb3150865b33b03846cf38d1b512fbae575d3f54f7d38a829?context=explore)

压缩后镜像大小：831.25 MB

本次更新仅在[v0.3版本](release-notes#v03)基础上做了一个重要改动：

- 强制将compute runtime中可用显存大小设为100%。

在Windows 11 22H2 22621.1848 + i9-13900 + Arc A770 (Windows driver: 31.0.101.4502)环境下测试通过。

对于A770，现在Web UI中检测到的显存大小从13005增加到了16256MB。

```txt
v0.3及以前 >>>> Torch detected GPU: Intel(R) Graphics [0x56a0] VRAM 13005 Compute Units 512
v0.4 >>>>>>>>> Torch detected GPU: Intel(R) Graphics [0x56a0] VRAM 16256 Compute Units 512
```

## [v0.3](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.3/images/sha256-accb961e63a14b92567e7c594ad5222fd4592a40b8e3c5a76310a70257b1f00e?context=explore)

压缩后镜像大小：831.25 MB

重要通知：

* IPEX在WSL2中存在严重的显存泄漏问题（ https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/issues/8, https://github.com/intel/intel-extension-for-pytorch/issues/388 ），现已在SD.Next https://github.com/vladmandic/automatic/commit/c3a4293f2227fe77b9ea908c99a1bda2aef43175 中临时解决。**如果你使用的是WSL，请根据[这里的指示](getting-started.md#更新sdnext源代码)将SD.Next代码更新。**

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

# Release Notes

## [v0.4](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.4/images/sha256-ca5ba4aab952e6afb3150865b33b03846cf38d1b512fbae575d3f54f7d38a829?context=explore) (latest)

Compressed image size: 831.25 MB

This release only includes one major change on top of [release v0.3](release-notes#v03):

- Force 100% available VRAM size for compute runtime.

Tested on Windows 11 22H2 22621.1848 with i9-13900 + Arc A770 (Windows driver: 31.0.101.4502)

For A770, now VRAM size increases from 13005 to 16256 MB.

```txt
v0.3 or earilier >>>> Torch detected GPU: Intel(R) Graphics [0x56a0] VRAM 13005 Compute Units 512
v0.4 >>>>>>>>>>>>>>>> Torch detected GPU: Intel(R) Graphics [0x56a0] VRAM 16256 Compute Units 512
```

## [v0.3](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.3/images/sha256-accb961e63a14b92567e7c594ad5222fd4592a40b8e3c5a76310a70257b1f00e?context=explore)

Compressed image size: 831.25 MB

Important notes:

* The severe VRAM leak problem of IPEX in WSL2 (https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/issues/8, https://github.com/intel/intel-extension-for-pytorch/issues/388) has been worked around in SD.Next https://github.com/vladmandic/automatic/commit/c3a4293f2227fe77b9ea908c99a1bda2aef43175. **If you are using WSL, please be sure to upgrade your SD.Next codebase by following [this instruction](getting-started.md#upgrade-sdnext-source-code).**

Major changes:

* Enable TCMalloc to mitigate the RAM leak problem in WSL.
* Mount `/root/.cache/huggingface` to avoid re-downloading huggingface models.

The image (Ubuntu 22.04 based) includes:

- Intel oneAPI DPC++ runtime libs (2023.1) (Note: compiler executables are not included)
- Intel oneAPI MKL runtime libs (2023.1)
- Intel oneAPI compiler common tool sycl-ls (2023.1)
- Intel Graphics driver (1.3.26241.21-647~22.04)
- Basic python environment (3.10.6)

Tested on Windows 11 22H2 22621.1848 with i9-13900 + Arc A770 (Windows driver: 31.0.101.4502)

## [v0.2](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.2/images/sha256-58f7c7ae5b837b427623472a23582c1b4ecbd49460d245ddcb533e721cb396db?context=explore)

Compressed image size: 827.1 MB

Major changes:
- Removed IPEX and python packages required by SD.Next from the image to reduce size.
- Removed other unnecessary compiler tools (except sycl-ls) to reduce size.
- Uplift Intel Graphics driver to 1.3.26241.21-647~22.04.

The image (Ubuntu 22.04 based) includes:

- Intel oneAPI DPC++ runtime libs (2023.1) (Note: compiler executables are not included)
- Intel oneAPI MKL runtime libs (2023.1)
- Intel oneAPI compiler common tool sycl-ls (2023.1)
- Intel Graphics driver (1.3.26241.21-647~22.04)
- Basic python environment (3.10.6)

Tested on Windows 11 22H2 22621.1848 with i9-13900 + Arc A770 (Windows driver: 31.0.101.4382)

## [v0.1](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.1/images/sha256-5c00e46920a396a2b1c69e5ad24218883ba205afe6d59ce153f12f684ef2c006)

Compressed image size: 2.11 GB

Initial release. The image (Ubuntu 22.04 based) includes:

- Intel oneAPI DPC++ runtime libs (2023.1) (Note: compiler executables are not included)
- Intel oneAPI MKL runtime libs (2023.1)
- Intel oneAPI compiler common tool sycl-ls (2023.1)
- Intel Graphics driver (1.3.25593.18-601~22.04)
- Basic python environment (3.10.6)
- IPEX (1.13.120+xpu) and python packages required by SD.Next requirements.txt

Tested on Windows 11 22H2 22621.1848 with i9-13900 + Arc A770 (Windows driver: 31.0.101.4382)

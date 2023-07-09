# Release Notes

## [v0.2](https://hub.docker.com/layers/nuullll/ipex-arc-sd/v0.2/images/sha256-58f7c7ae5b837b427623472a23582c1b4ecbd49460d245ddcb533e721cb396db?context=explore) (latest)

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

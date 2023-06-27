# Stable Diffusion Web UI Docker for Intel Arc GPUs

<a href="https://hub.docker.com/r/nuullll/ipex-arc-sd">
  <img src="https://img.shields.io/docker/pulls/nuullll/ipex-arc-sd" />
</a>

The [docker image](https://hub.docker.com/r/nuullll/ipex-arc-sd) includes
- Intel oneAPI DPC++ runtime libs _(Note: compiler executables are not included)_
- Intel oneAPI MKL runtime libs
- Intel oneAPI compiler common tool `sycl-ls`
- Intel Graphics driver
- Basic python environment

The Stable Diffusion Web UI variant used by the image: [SD.Next](https://github.com/vladmandic/automatic)

- Intel Extension for Pytorch (IPEX) and other python packages will be installed by [SD.Next](https://github.com/vladmandic/automatic) dynamically

## Run docker container

### Windows (PowerShell)

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

### Linux (Shell)

```sh
docker run -it \
--device /dev/dri \
-v ~/docker-mount/sd-webui:/sd-webui \
-v deps:/deps \
-p 7860:7860 \
--name sd-server \
nuullll/ipex-arc-sd:v0.1
```

### Parameters

1. `-it` to see logging output interactively
2. `--device /dev/dri` on Linux or `--device /dev/dxg` and `-v /usr/lib/wsl:/usr/lib/wsl` on Windows are required to enable container GPU access. See [wslg samples](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md#containerized-applications-access-to-the-vgpu) for details.
3. `-v <host_mount_dir>:/sd-webui` specifies a directory on host to be [bind-mounted](https://docs.docker.com/storage/bind-mounts/) to `/sd-webui` directory inside the container. When you launch the container for the first time, you should specify an empty or non-existent directory on host as `<host_mount_dir>`, so that the container can pull [SD.Next](https://github.com/vladmandic/automatic) source code into the corresponding directory. If you want to launch another container (e.g. [overriding the docker entrypoint](https://docs.docker.com/engine/reference/run/#entrypoint-default-command-to-execute-at-runtime)) that shares the initialized Web UI folder, you should specify the same `<host_mount_dir>`.
4. `-v deps:/deps` specifies a [volume](https://docs.docker.com/storage/volumes/) managed by the docker engine, named as `deps` (just choose any name you like), to be mounted as `/deps` directory inside the container. `/deps` is configured (see `./startup.sh`) to store all dynamic python dependencies (e.g. packages needed by Web UI extensions) required after the Web UI launches. You can mount the `deps` volume to multiple containers so that those dynamic dependencies would be downloaded and installed only once. This is useful for users who want to run containers with different Web UI arguments (e.g. `--debug`), and for those who actually build local docker images.
5. `-p 7860:7860` specifies the [published port](https://docs.docker.com/network/).
6. `--name <container_name>` assigns the container a meaningful name. You can restart the same container (after it exits) by `docker start -i <container_name>`.
7. `nuullll/ipex-arc-sd:v0.1` specifies the docker image. If it doesn't exist locally, docker will pull from the [corresponding dockerhub registry](https://hub.docker.com/r/nuullll/ipex-arc-sd).

## (For Developers) Build docker image locally

```powershell
docker build -t ipex-arc-sd -f Dockerfile .
```

Refer to [Dockerfile](./Dockerfile) for available build arguments.

## Contributors

<a href="https://github.com/Nuullll/ipex-sd-docker-for-arc-gpu/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=Nuullll/ipex-sd-docker-for-arc-gpu" />
</a>

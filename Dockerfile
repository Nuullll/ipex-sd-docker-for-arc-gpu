#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

ARG UBUNTU_VERSION

FROM ubuntu:${UBUNTU_VERSION}

VOLUME [ "/sd-webui" ]
WORKDIR /sd-webui

ENV LANG=C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive

HEALTHCHECK NONE
RUN useradd -d /home/ipex -m -s /bin/bash ipex

RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    apt-utils \
    build-essential \
    ca-certificates \
    clinfo \
    curl \
    git \
    gnupg2 \
    gpg-agent \
    rsync \
    sudo \
    unzip \
    wget && \
    apt-get clean && \
    rm -rf  /var/lib/apt/lists/*

ARG DEVICE

RUN no_proxy=$no_proxy wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | \
    gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
RUN printf 'deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy %s\n' "$DEVICE" | \
    tee  /etc/apt/sources.list.d/intel.gpu.jammy.list

ARG ICD_VER
ARG LEVEL_ZERO_GPU_VER
ARG LEVEL_ZERO_VER
ARG LEVEL_ZERO_DEV_VER

RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    intel-opencl-icd=${ICD_VER} \
    intel-level-zero-gpu=${LEVEL_ZERO_GPU_VER} \
    level-zero=${LEVEL_ZERO_VER} \
    level-zero-dev=${LEVEL_ZERO_DEV_VER} && \
    apt-get clean && \
    rm -rf  /var/lib/apt/lists/*

RUN no_proxy=$no_proxy wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
   | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
   echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
   | tee /etc/apt/sources.list.d/oneAPI.list

ARG DPCPP_VER
ARG MKL_VER

# Install standalone components instead of runtime libs
RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    intel-oneapi-dpcpp-cpp-${DPCPP_VER} \
    intel-oneapi-mkl-${MKL_VER}

ARG PYTHON

RUN apt-get update && apt-get install -y --no-install-recommends --fix-missing \
    ${PYTHON} lib${PYTHON} python3-pip python3-venv && \
    apt-get clean && \
    rm -rf  /var/lib/apt/lists/*

RUN pip --no-cache-dir install --upgrade \
    pip \
    setuptools

RUN ln -sf $(which ${PYTHON}) /usr/local/bin/python && \
    ln -sf $(which ${PYTHON}) /usr/local/bin/python3 && \
    ln -sf $(which ${PYTHON}) /usr/bin/python && \
    ln -sf $(which ${PYTHON}) /usr/bin/python3

RUN no_proxy=$no_proxy wget http://registrationcenter-download.intel.com/akdlm/IRC_NAS/89283df8-c667-47b0-b7e1-c4573e37bd3e/2023.1-linux-hotfix.zip && \
    unzip 2023.1-linux-hotfix.zip && \
    cp 2023.1-linux-hotfix/libpi_level_zero.so /opt/intel/oneapi/compiler/2023.1.0/linux/lib/

RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    libgl1 libglib2.0-0

ARG TORCH_VERSION
ARG TORCHVISION_VERSION
ARG IPEX_VERSION
ARG IPEX_WHL_URL
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install torch==${TORCH_VERSION} \
                intel_extension_for_pytorch==${IPEX_VERSION} \
                torchvision==${TORCHVISION_VERSION} -f ${IPEX_WHL_URL}

COPY requirements.txt /tmp/
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r /tmp/requirements.txt

COPY startup.sh /bin/

CMD [ "startup.sh", "--use-intel-oneapi", "--server-name=0.0.0.0" ]

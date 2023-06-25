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

ARG PYTHON
RUN apt-get update && apt-get install -y --no-install-recommends --fix-missing \
    ${PYTHON} lib${PYTHON} python3-pip && \
    apt-get clean && \
    rm -rf  /var/lib/apt/lists/*

RUN pip --no-cache-dir install --upgrade \
    pip \
    setuptools

RUN ln -sf $(which ${PYTHON}) /usr/local/bin/python && \
    ln -sf $(which ${PYTHON}) /usr/local/bin/python3 && \
    ln -sf $(which ${PYTHON}) /usr/bin/python && \
    ln -sf $(which ${PYTHON}) /usr/bin/python3

# oneAPI packages
RUN no_proxy=$no_proxy wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
   | gpg --dearmor | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null && \
   echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
   | tee /etc/apt/sources.list.d/oneAPI.list

ARG DPCPP_VER
ARG MKL_VER
# intel-oneapi-compiler-shared-common provides `sycl-ls`
ARG CMPLR_COMMON_VER
# Install runtime libs to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    intel-oneapi-runtime-dpcpp-cpp=${DPCPP_VER} \
    intel-oneapi-runtime-mkl=${MKL_VER} \
    intel-oneapi-compiler-shared-common-${CMPLR_COMMON_VER}

# oneAPI 2023.1 hostfix
RUN no_proxy=$no_proxy wget http://registrationcenter-download.intel.com/akdlm/IRC_NAS/89283df8-c667-47b0-b7e1-c4573e37bd3e/2023.1-linux-hotfix.zip && \
    unzip 2023.1-linux-hotfix.zip && \
    cp 2023.1-linux-hotfix/libpi_level_zero.so /opt/intel/oneapi/lib/libpi_level_zero.so && \
    cp 2023.1-linux-hotfix/libpi_level_zero.so /opt/intel/opencl/libpi_level_zero.so && \
    rm -rf 2023.1-linux-hotfix.zip 2023.1-linux-hotfix/

# Set oneAPI lib env
ENV PATH=/opt/intel/oneapi/compiler/${CMPLR_COMMON_VER}/linux/bin:$PATH
ENV LD_LIBRARY_PATH=/opt/intel/oneapi/lib:/opt/intel/oneapi/lib/intel64:$LD_LIBRARY_PATH

# Intel Graphics driver
ARG DEVICE
RUN no_proxy=$no_proxy wget -qO - https://repositories.intel.com/graphics/intel-graphics.key | \
    gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
RUN printf 'deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy %s\n' "$DEVICE" | \
    tee /etc/apt/sources.list.d/intel.gpu.jammy.list

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

# Stable Diffusion Web UI dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends --fix-missing \
    libgl1 \
    libglib2.0-0 \
    python3-venv \
    numactl && \
    apt-get clean && \
    rm -rf  /var/lib/apt/lists/*

COPY startup.sh /bin/
RUN chmod 755 /bin/startup.sh

VOLUME [ "/deps" ]
VOLUME [ "/sd-webui" ]

ENV venv_dir=/deps/venv
WORKDIR /sd-webui

ENTRYPOINT [ "startup.sh", "-f", "--use-ipex", "--listen" ]
STAGE_DIR=/tmp
mkdir -p ${STAGE_DIR}

sudo apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common build-essential autotools-dev \
    nfs-common pdsh \
    cmake g++ gcc \
    curl wget vim tmux emacs less unzip \
    htop iftop iotop ca-certificates openssh-client openssh-server \
    rsync iputils-ping net-tools sudo \
    llvm-9-dev

sudo add-apt-repository ppa:git-core/ppa -y && \
    apt-get update && \
    apt-get install -y git && \
    git --version

echo "ClientAliveInterval 30" >> /etc/ssh/sshd_config

STAGE_DIR=/tmp; cp /etc/ssh/sshd_config ${STAGE_DIR}/sshd_config && \
    sed "0,/^#Port 22/s//Port 22/" ${STAGE_DIR}/sshd_config > /etc/ssh/sshd_config

STAGE_DIR=/tmp; MLNX_OFED_VERSION=4.6-1.0.1.1; apt-get install -y libnuma-dev; cd ${STAGE_DIR} && \
    wget -q -O - http://www.mellanox.com/downloads/ofed/MLNX_OFED-${MLNX_OFED_VERSION}/MLNX_OFED_LINUX-${MLNX_OFED_VERSION}-ubuntu18.04-x86_64.tgz | tar xzf - && \
    cd MLNX_OFED_LINUX-${MLNX_OFED_VERSION}-ubuntu18.04-x86_64 && \
    ./mlnxofedinstall --user-space-only --without-fw-update --all -q && \
    cd ${STAGE_DIR} && \
    rm -rf ${STAGE_DIR}/MLNX_OFED_LINUX-${MLNX_OFED_VERSION}-ubuntu18.04-x86_64*

STAGE_DIR=/tmp; NV_PEER_MEM_VERSION=1.1; NV_PEER_MEM_TAG=1.1-0; mkdir -p ${STAGE_DIR} && \
    git clone https://github.com/Mellanox/nv_peer_memory.git --branch ${NV_PEER_MEM_TAG} ${STAGE_DIR}/nv_peer_memory && \
    cd ${STAGE_DIR}/nv_peer_memory && \
    ./build_module.sh && \
    cd ${STAGE_DIR} && \
    tar xzf ${STAGE_DIR}/nvidia-peer-memory_${NV_PEER_MEM_VERSION}.orig.tar.gz && \
    cd ${STAGE_DIR}/nvidia-peer-memory-${NV_PEER_MEM_VERSION} && \
    apt-get update && \
    apt-get install -y dkms && \
    dpkg-buildpackage -us -uc && \
    dpkg -i ${STAGE_DIR}/nvidia-peer-memory_${NV_PEER_MEM_TAG}_all.deb

STAGE_DIR=/tmp; OPENMPI_BASEVERSION=4.0; OPENMPI_VERSION=${OPENMPI_BASEVERSION}.1; cd ${STAGE_DIR} && \
    wget -q -O - https://download.open-mpi.org/release/open-mpi/v${OPENMPI_BASEVERSION}/openmpi-${OPENMPI_VERSION}.tar.gz | tar xzf - && \
    cd openmpi-${OPENMPI_VERSION} && \
    ./configure --prefix=/usr/local/openmpi-${OPENMPI_VERSION} && \
    make -j"$(nproc)" install && \
    ln -s /usr/local/openmpi-${OPENMPI_VERSION} /usr/local/mpi && \
    test -f /usr/local/mpi/bin/mpic++ && \
    cd ${STAGE_DIR} && \
    rm -r ${STAGE_DIR}/openmpi-${OPENMPI_VERSION}; PATH=/usr/local/mpi/bin:${PATH} \
    LD_LIBRARY_PATH=/usr/local/lib:/usr/local/mpi/lib:/usr/local/mpi/lib64:${LD_LIBRARY_PATH}

mv /usr/local/mpi/bin/mpirun /usr/local/mpi/bin/mpirun.real && \
    echo '#!/bin/bash' > /usr/local/mpi/bin/mpirun && \
    echo 'mpirun.real --allow-run-as-root --prefix /usr/local/mpi "$@"' >> /usr/local/mpi/bin/mpirun && \
    chmod a+x /usr/local/mpi/bin/mpirun

DEBIAN_FRONTEND=noninteractive; PYTHON_VERSION=3; apt-get install -y python3 python3-dev && \
    rm -f /usr/bin/python && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    curl -O https://bootstrap.pypa.io/get-pip.py && \
        python get-pip.py && \
        rm get-pip.py && \
    pip install --upgrade pip && \
    python -V && pip -V

pip install pyyaml
pip install ipython

TENSORFLOW_VERSION=1.15.2; pip install tensorflow-gpu==${TENSORFLOW_VERSION}

apt-get update && \
    apt-get install -y --no-install-recommends \
        libsndfile-dev \
        libcupti-dev \
        libjpeg-dev \
        libpng-dev \
        screen

pip install psutil \
                yappi \
                cffi \
                ipdb \
                pandas \
                matplotlib \
                py3nvml \
                pyarrow \
                graphviz \
                astor \
                boto3 \
                tqdm \
                sentencepiece \
                msgpack \
                requests \
                pandas \
                sphinx \
                sphinx_rtd_theme \
                scipy \
                numpy \
                sklearn \
                scikit-learn \
                nvidia-ml-py3 \
                mpi4py \
                cupy-cuda100


SSH_PORT=2222; cat /etc/ssh/sshd_config > ${STAGE_DIR}/sshd_config && \
    sed "0,/^#Port 22/s//Port ${SSH_PORT}/" ${STAGE_DIR}/sshd_config > /etc/ssh/sshd_config


PYTORCH_VERSION=1.2.0; TORCHVISION_VERSION=0.4.0; TENSORBOARDX_VERSION=1.8; pip install torch==${PYTORCH_VERSION}; pip install torchvision==${TORCHVISION_VERSION}; pip install tensorboardX==${TENSORBOARDX_VERSION}

rm -rf /usr/lib/python3/dist-packages/yaml && \
    rm -rf /usr/lib/python3/dist-packages/PyYAML-*


git submodule update --init --recursive

cd third_party/apex
git fetch
git checkout ''

sed -e 72's/.*/#&/' setup.py > _test.py && mv _test.py setup.py
sed -e 73's/.*/#&/' setup.py > _test.py && mv _test.py setup.py
sed -e 74's/.*/#&/' setup.py > _test.py && mv _test.py setup.py
sed -e 75's/.*/#&/' setup.py > _test.py && mv _test.py setup.py
sed -e 76's/.*/#&/' setup.py > _test.py && mv _test.py setup.py
sed -e 77's/.*/#&/' setup.py > _test.py && mv _test.py setup.py
sed -e 78's/.*/#&/' setup.py > _test.py && mv _test.py setup.py
cd ..
cd ..
sudo bash install.sh --allow_sudo


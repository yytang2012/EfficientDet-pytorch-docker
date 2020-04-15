ARG IMAGE_NAME=nvidia/cuda
FROM ${IMAGE_NAME}:10.1-devel-ubuntu18.04 AS base
LABEL maintainer="Yutao Tang <kissingers800@gmail.com>"

ARG CUDNN_VERSION=7.6.4.38
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=${CUDNN_VERSION}-1+cuda10.1 \
            libcudnn7-dev=${CUDNN_VERSION}-1+cuda10.1 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs


## Install TensorRT. Requires that libcudnn7 is installed above.
#ARG LIB_VERSION=6.0.1
#RUN apt-get install -y --no-install-recommends libnvinfer6=${LIB_VERSION}-1+cuda10.1 \
#    libnvinfer-dev=${LIB_VERSION}-1+cuda10.1 \
#    libnvinfer-plugin6=${LIB_VERSION}-1+cuda10.1

FROM base AS ubuntu-cudnn

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        python3-dev python3-pip python3-setuptools libgtk2.0-dev git g++ wget make vim

# Upgrade pip to latest version is necessary, otherwise the default version cannot install tensorflow 2.1.0
RUN pip3 install --upgrade setuptools pip

#for python packages
RUN pip3 install cython \
        numpy>=1.14 \
        wheel \
        opencv-python==3.4.5.20 \
        tensorflow-gpu

# for coco api
RUN pip3 install git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI

FROM ubuntu-cudnn AS efficientDet-prepare

# Download source code
WORKDIR /efficientdet
RUN git clone https://github.com/zylo117/Yet-Another-EfficientDet-Pytorch.git .

# Install Dependencies
RUN pip3 install opencv-python==3.4.5.20 \
        tqdm \
        tensorboard \
        tensorboardX \
        pyyaml \
        torch==1.4.0 \
        torchvision==0.5.0


FROM efficientDet-prepare AS efficientDet
COPY item.yml /efficientdet/projects/


# Healthcheck
HEALTHCHECK CMD pidof python3 || exit 1


CMD ["/bin/bash"]


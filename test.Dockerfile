# build
FROM nvidia/cuda:11.1-cudnn8-runtime-ubuntu18.04
# COPY ./ /test

# CUDA
RUN echo 'export PATH=/usr/local/cuda-11.0/bin${PATH:+:${PATH}}' >> ~/.bashrc 
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc 
RUN echo 'export PATH=/usr/local/cuda/bin:/$PATH' >> ~/.bashrc 
RUN echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> ~/.bashrc 

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    libgl1-mesa-glx \
    # python3-dev \
    # python3-pip \
    # ca-certificates \
    # libglib2.0-0 \
    # libxext6 \
    # libsm6 \
    # libxrender1 \
    # libssl-dev \
    # libzmq3-dev \
    git

RUN apt-get update

RUN python3.8 -m venv /venv
ENV PATH=/venv/bin:$PATH

RUN echo $PATH
RUN . activate venv

# WORKDIR /test

# RUN pip3 install -r requirments_docker.txt
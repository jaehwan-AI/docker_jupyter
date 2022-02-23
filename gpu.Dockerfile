# build
FROM tensorflow/tensorflow:2.6.0-gpu-jupyter
FROM nvidia/cuda:11.2.1-cudnn8-devel-ubuntu18.04 AS nvidia

COPY ./ /test

# CUDA
ENV CUDA_MAJOR_VERSION=11
ENV CUDA_MINOR_VERSION=2
ENV CUDA_VERSION=$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/opt/bin:${PATH}

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
ENV LD_LIBRARY_PATH_NO_STUBS="/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/opt/conda/lib"
ENV LD_LIBRARY_PATH="/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs:/opt/conda/lib"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION"


# openjdk java vm 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    g++ \
    gcc \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    curl \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    libssl-dev \
    libzmq3-dev \
    vim \
    git

RUN apt-get update

ARG CONDA_DIR=/opt/conda

# add to path
ENV PATH $CONDA_DIR/bin:$PATH

# install miniconda
RUN echo "export PATH=$CONDA_DIR/bin:"'$PATH' > /etc/profile.d/conda.sh && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-py37_4.10.3-Linux-x86_64.sh -o ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# conda create env
RUN conda config --set always_yes yes --set changeps1 no && \
    conda create -y -q -n py37 python=3.7

ENV PATH /opt/conda/envs/py37/bin:$PATH
ENV CONDA_DEFAULT_ENV py37
ENV CONDA_PREFIX /opt/conda/envs/py37

# install package
RUN pip install setuptools && \
    pip install mkl && \
    pip install pymysql && \
    pip install numpy && \
    pip install scipy && \
    pip install pandas==1.2.5 && \
    pip install jupyter notebook && \
    pip install matplotlib && \
    pip install seaborn && \
    pip install hyperopt && \
    pip install optuna && \
    pip install missingno && \
    pip install mlxtend && \
    pip install catboost && \
    pip install kaggle && \
    pip install folium && \
    pip install librosa && \
    pip install nbconvert && \
    pip install Pillow && \
    pip install tqdm && \
    pip install tensorflow==2.6.0 && \
    pip install tensorflow-datasets && \
    pip install gensim && \
    pip install nltk && \
    pip install wordcloud && \
    apt-get install -y graphviz && pip install graphviz && \
    pip install cupy-cuda112

# install cmake (3.16)
RUN wget https://cmake.org/files/v3.16/cmake-3.16.2.tar.gz && \
    tar -xvzf cmake-3.16.2.tar.gz && \
    cd cmake-3.16.2 && \
    ./bootstrap && \
    make && \
    make install

ENV PATH=/usr/local/bin:${PATH}

# matplotlib에 Nanum 폰트 추가
RUN apt-get install fonts-nanum* && \
    cp /usr/share/fonts/truetype/nanum/Nanum* /opt/conda/envs/py37/lib/python3.7/site-packages/matplotlib/mpl-data/fonts/ttf/ && \
    fc-cache -fv && \
    rm -rf ~/.cache/matplotlib/*

# Remove the CUDA stubs
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH_NO_STUBS"

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    conda clean -a -y

# LANG env
ENV LANG ko_KR.UTF-8

# directory
WORKDIR /test

# Jupyter Notebook config 파일 생성
RUN jupyter notebook --generate-config

# config 파일 복사 (jupyter_notebook_config.py 파일 참고)
COPY jupyter_notebook_config.py /home/.jupyter/jupyter_notebook_config.py

# 설치 완료 후 테스트용 ipynb
COPY test.ipynb /home/user/test.ipynb

# port
EXPOSE 8887

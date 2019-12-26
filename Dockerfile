FROM ubuntu:18.04
LABEL version="3.5.2"
LABEL description="Docker image for running Singularity containers"
LABEL maintainer="https://github.com/dmey"

ARG SINGULARITY_VERSION=3.5.2

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    software-properties-common \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup

# Install go (https://github.com/golang/go/wiki/Ubuntu)
RUN add-apt-repository ppa:longsleep/golang-backports \
    && apt-get update \
    && apt-get install -y golang-go

# Install Singualrity
RUN cd /tmp \
    && wget https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VERSION}/singularity-${SINGULARITY_VERSION}.tar.gz \
    && tar -xzf singularity-${SINGULARITY_VERSION}.tar.gz \
    && cd singularity \
    && ./mconfig \
    && make -C builddir \
    && make -C builddir install \
    && rm -rf /tmp/*

# Guard against "container creation failed" error in Singualrity due to nonexisting folder
RUN mkdir -p /etc/localtime

# Clean up
RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
# docker image for developing and testing Veracruz.
#
# AUTHORS
#
# The Veracruz Development Team.
#
# COPYRIGHT
#
# See the `LICENSE.markdown` file in the Veracruz root directory for licensing
# and copyright information.
#
# NOTE: We try to follow the guide in https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
#       Each RUN contains a bundle of steps, which reduces the cache.

# syntax = docker/dockerfile:1.2

FROM ubuntu:18.04 AS veracruz_build_base

ARG USER
ARG UID

ENV DEBIAN_FRONTEND noninteractive
ENV RUSTUP_HOME=/cache/rustup \
    CARGO_HOME=/cache/cargo \
    XARGO_HOME=/cache/xargo \
    SCCACHE_DIR=/cache/sccache \
    SCCACHE_CACHE_SIZE=10G \
    PATH=/cache/cargo/bin:$PATH \
    RUST_VERSION=1.48.0

COPY sources.list /etc/apt/sources.list
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt --mount=type=cache,target=/var/lib/apt \
    dpkg --add-architecture arm64 && \
    apt-get update && apt-get install --no-install-recommends -y \
        autoconf \
        automake \
        bc \
        bison \
        build-essential \
        ca-certificates \
        clang \
        cmake \
        cpio \
        flex \
        git \
        gcc \
        iasl \
        less \
        libattr1-dev \
        libc6-dev \
        libc6-dev-i386 \
        libclang-dev \
        libcurl4-openssl-dev \
	libcurl4-openssl-dev:arm64 \
        libsqlite3-dev \ 
        libssl-dev \
        libtool \
        libglib2.0-dev \
        libcap-dev \
        libcap-ng-dev \
        libpixman-1-dev \
        libfdt-dev \
        libprotobuf-dev \
	libsqlite3-dev:arm64 \
	libssl-dev:arm64 \
        musl \
        musl-dev \
        musl-tools \
        python \
        zlib1g-dev \
        llvm-dev \
        make \
        curl \
        unzip \
        protobuf-c-compiler \
        protobuf-compiler \
        python \
        python-crypto \
        python-pip \
        python3 \
        python3-pip \ 
        python3-pyelftools \ 
        pkg-config \
        rsync \
	screen \
        sqlite3 \
        uuid-dev \
        wget \
        xxd \
        ; \
    pip install pycryptodome; \
    pip3 install pycryptodome; \
    rm -rf /tmp/* /var/tmp/*

WORKDIR /work

# Link the user's toolchain to the global toolchain directory
RUN if [ "$USER" != "root" ] ; then \
        useradd -u $UID -m -p deadbeef -s /bin/bash $USER ; \
        mkdir -p /home/$USER/.rustup ; \
        ln -s /usr/local/rustup/toolchains /home/$USER/.rustup ; \
        chown -R $USER /work ; \
    fi

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='49c96f3f74be82f4752b8bffcf81961dea5e6e94ce1ccba94435f12e871c3bdb' ;; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='5a2be2919319e8778698fa9998002d1ec720efe7cb4f6ee4affb006b5e73f1be' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='d93ef6f91dab8299f46eef26a56c2d97c66271cea60bf004f2f088a86a697078' ;; \
        i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='e3d0ae3cfce5c6941f74fed61ca83e53d4cd2deb431b906cbd0687f246efede4' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    wget "https://static.rust-lang.org/rustup/archive/1.22.1/${rustArch}/rustup-init" ; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c - ; \
    chmod +x rustup-init ; mv rustup-init /usr/bin ; \
    mkdir -p $RUSTUP_HOME $CARGO_HOME $XARGO_HOME ; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME $XARGO_HOME ; \
    if [ "$USER" != "root" ] ; then \
        chown -R $USER $RUSTUP_HOME $CARGO_HOME $XARGO_HOME; \
    fi

RUN --mount=type=bind,source=sgx,target=/sgx,rw \
    mkdir /etc/init -p ; \
    dpkg -i /sgx/libsgx-enclave-common_2.5.101.50123-bionic1_amd64.deb && \
    dpkg -i /sgx/libsgx-enclave-common-dev_2.5.101.50123-bionic1_amd64.deb && \
    dpkg -i /sgx/libsgx-enclave-common-dbgsym_2.5.101.50123-bionic1_amd64.ddeb && \
    chmod a+x /sgx/sgx_linux_x64_sdk_2.9.101.2.bin ; \
    echo "yes" | /sgx/sgx_linux_x64_sdk_2.9.101.2.bin ; \
    echo source /work/sgxsdk/environment >> /etc/profile

ENV CC_aarch64_unknown_optee_trustzone /work/rust-optee-trustzone-sdk/optee/toolchains/aarch64/bin/aarch64-linux-gnu-gcc
ENV C_INCLUDE_PATH /work/sgxsdk/include
COPY init.sh /root/init.sh

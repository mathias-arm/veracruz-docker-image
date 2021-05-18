#!/bin/bash

dpkgArch="$(dpkg --print-architecture)"; \
case "${dpkgArch##*-}" in \
    amd64) rustArch='x86_64-unknown-linux-gnu' ;; \
    armhf) rustArch='armv7-unknown-linux-gnueabihf' ;; \
    arm64) rustArch='aarch64-unknown-linux-gnu' ;; \
    i386) rustArch='i686-unknown-linux-gnu' ;; \
    *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
esac

rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host "${rustArch}"
rustup component add rust-src
cargo install xargo
cargo install sccache
cargo install diesel_cli --no-default-features --features sqlite
rustup target add x86_64-unknown-linux-musl
rustup target add aarch64-unknown-linux-gnu


# wget https://download.01.org/intel-sgx/linux-2.5/ubuntu18.04-server/libsgx-enclave-common_2.5.101.50123-bionic1_amd64.deb
# wget https://download.01.org/intel-sgx/linux-2.5/ubuntu18.04-server/libsgx-enclave-common-dev_2.5.101.50123-bionic1_amd64.deb
# wget https://download.01.org/intel-sgx/linux-2.5/ubuntu18.04-server/libsgx-enclave-common-dbgsym_2.5.101.50123-bionic1_amd64.ddeb
# wget https://download.01.org/intel-sgx/sgx-linux/2.9.1/distro/ubuntu18.04-server/sgx_linux_x64_sdk_2.9.101.2.bin
# 
# mkdir /etc/init -p
# dpkg -i libsgx-enclave-common_2.5.101.50123-bionic1_amd64.deb \
#     libsgx-enclave-common-dev_2.5.101.50123-bionic1_amd64.deb \
#     libsgx-enclave-common-dbgsym_2.5.101.50123-bionic1_amd64.ddeb
# 
# rm libsgx-enclave-common_2.5.101.50123-bionic1_amd64.deb \
#     libsgx-enclave-common-dev_2.5.101.50123-bionic1_amd64.deb \
#     libsgx-enclave-common-dbgsym_2.5.101.50123-bionic1_amd64.ddeb
# 
# chmod a+x ./sgx_linux_x64_sdk_2.9.101.2.bin
# echo "yes" | ./sgx_linux_x64_sdk_2.9.101.2.bin
# rm sgx_linux_x64_sdk_2.9.101.2.bin


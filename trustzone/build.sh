#!/bin/bash

export TZDIR=/work/rust-optee-trustzone-sdk
export ROOT="${TZDIR}/optee"

if ! [ -d ${TZDIR} ] ; then \
    git clone --depth 1 --branch veracruz --recursive \
        https://github.com/veracruz-project/rust-optee-trustzone-sdk.git ${TZDIR}; \
fi

rsync -a patch/bget.c ${TZDIR}/optee/optee_os/lib/libutils/isoc/
rsync -a patch/mempool.c ${TZDIR}/optee/optee_os/lib/libutils/ext/

make -C ${TZDIR} toolchains
make -C ${TZDIR} optee

git config --global user.email "you@example.com"
git config --global user.name "Your Name"

mkdir -p ${TZDIR}/optee-qemuv8-3.7.0
cd ${TZDIR}/optee-qemuv8-3.7.0
../../repo init -q -u https://github.com/veracruz-project/OPTEE-manifest.git -m qemu_v8.xml -b veracruz | tee repo.log
../../repo sync -c --no-tags --no-clone-bundle
cd "$OLDPWD"

# dpkg --add-architecture arm64
# rsync -a patch/sources.list /etc/apt/sources.list
# apt update
# apt install libsqlite3-dev:arm64 libssl-dev:arm64 uuid-dev iasl

rsync -a patch/platform_def.h ${TZDIR}/optee-qemuv8-3.7.0/trusted-firmware-a/plat/qemu/include/
rsync -a patch/conf.mk ${TZDIR}/optee-qemuv8-3.7.0/optee_os/core/arch/arm/plat-vexpress/
rsync -a patch/core_mmu_lpae.c ${TZDIR}/optee-qemuv8-3.7.0/optee_os/core/arch/arm/mm/
rsync -a patch/pgt_cache.h ${TZDIR}/optee-qemuv8-3.7.0/optee_os/core/arch/arm/include/mm/
rsync -a patch/environment ${TZDIR}/
rsync -a patch/build_optee.sh patch/qemu_v8.mk ${TZDIR}/optee-qemuv8-3.7.0/build/

mkdir -p ${TZDIR}/rust-optee-trustzone-sdk/optee-qemuv8-3.7.0/out/bin

make -C ${ROOT} toolchains
# CC=$PWD/rust-optee-trustzone-sdk/optee-qemuv8-3.7.0/toolchains/aarch64/bin/aarch64-linux-gnu-gcc \

ROOT="${TZDIR}/optee-qemuv8-3.7.0" \
    PATH=${TZDIR}/optee-qemuv8-3.7.0/toolchains/aarch64/bin:$PATH \
    make CFG_TEE_CORE_DEBUG=n QEMU_VIRTFS_ENABLE=y CFG_TEE_RAM_VA_SIZE=0x00300000 -C ${TZDIR}/optee-qemuv8-3.7.0/build

echo "set print array on\nset print pretty on\n\ndefine optee\n\thandle SIGTRAP noprint nostop pass\n\tsymbol-file ${TZDIR}/optee-qemuv8-3.7.0/optee_os/out/arm/core/tee.elf\n\ttarget remote localhost:1234\nend\ndocument optee\n\tLoads and setup the binary (tee.elf) for OP-TEE and also connects to the QEMU\nremote.\n end" > ~/.gdbinit

rsync ../build_optee.sh ${TZDIR}/optee-qemuv8-3.7.0/build
rsync ../run_optee.sh ${TZDIR}/optee-qemuv8-3.7.0/build

echo <<EOF >> /etc/environment
if [ -f /work/rust-optee-trustzone-sdk/environment ] ; then
   cd  /work/rust-optee-trustzone-sdk ; source environment ; cd ${OLDPWD} ;
fi
EOF

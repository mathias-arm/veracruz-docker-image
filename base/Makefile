all:
	mkdir -p sgx ; \
	cd sgx ; \
	if ! [ -f libsgx-enclave-common_2.5.101.50123-bionic1_amd64.deb ] ; then \
		wget https://download.01.org/intel-sgx/linux-2.5/ubuntu18.04-server/libsgx-enclave-common_2.5.101.50123-bionic1_amd64.deb ; \
	fi ; \
	if ! [ -f libsgx-enclave-common-dev_2.5.101.50123-bionic1_amd64.deb ] ; then \
		wget https://download.01.org/intel-sgx/linux-2.5/ubuntu18.04-server/libsgx-enclave-common-dev_2.5.101.50123-bionic1_amd64.deb ; \
	fi ; \
	if ! [ -f libsgx-enclave-common-dbgsym_2.5.101.50123-bionic1_amd64.ddeb ] ; then \
		wget https://download.01.org/intel-sgx/linux-2.5/ubuntu18.04-server/libsgx-enclave-common-dbgsym_2.5.101.50123-bionic1_amd64.ddeb ; \
	fi ; \
	if ! [ -f sgx_linux_x64_sdk_2.9.101.2.bin ] ; then \
		wget https://download.01.org/intel-sgx/sgx-linux/2.9.1/distro/ubuntu18.04-server/sgx_linux_x64_sdk_2.9.101.2.bin ; \
	fi ; \
	chmod a+x sgx_linux_x64_sdk_2.9.101.2.bin


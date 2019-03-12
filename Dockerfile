ARG BASE_IMAGE=mcr.microsoft.com/dotnet/core/sdk:2.2.104
FROM $BASE_IMAGE AS build
ARG CORECLR_BRANCH=v2.2.2
RUN apt-get update && \
	apt-get install -y \
		cmake \
		llvm-4.0 \
		clang-4.0 \
		lldb-4.0 \
		liblldb-4.0-dev \
		libunwind8 \
		libunwind8-dev \
		gettext \
		libicu-dev \
		liblttng-ust-dev \
		libcurl4-openssl-dev \
		libssl-dev \
		uuid-dev \
		libnuma-dev \
		libkrb5-dev \
		git && \
	git clone https://github.com/dotnet/coreclr.git /coreclr
WORKDIR /coreclr
RUN git checkout $CORECLR_BRANCH
COPY patches /patches
RUN if [ -f /patches/$CORECLR_BRANCH.patch ] ; then git apply /patches/$CORECLR_BRANCH.patch ; fi
RUN ./build.sh clang4.0 

FROM $BASE_IMAGE
RUN apt-get update && \
	apt-get install -y \
		lldb-4.0 && \
	rm -rf /var/lib/apt/lists/* && \
	ln -s $(find /usr/share/dotnet/shared/Microsoft.NETCore.App/ -name createdump) /usr/bin/createdump
COPY --from=build /coreclr/bin/Product/Linux.x64.Debug /coreclr

ENV LLDB_BINARY_PATH ${LLDB_BINARY_PATH}
CMD ["/bin/bash", "-c", "lldb-4.0 /usr/bin/dotnet --core /tmp/coredump -o 'plugin load /coreclr/libsosplugin.so' -o 'sos PrintException'"]
	

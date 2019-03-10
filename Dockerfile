FROM microsoft/dotnet:2.0.3-sdk AS build

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
RUN git checkout release/2.0.0
COPY patches /patches
RUN git apply /patches/2.0.0.patch
RUN ./build.sh clang4.0 

FROM microsoft/dotnet:2.0.3-sdk
RUN apt-get update && \
	apt-get install -y \
		lldb-4.0 && \
	rm -rf /var/lib/apt/lists/*
COPY --from=build /coreclr/bin/Product/Linux.x64.Debug /coreclr
	

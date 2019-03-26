#!/usr/bin/env bash

docker build \
	--tag 6opuc/lldb-netcore \
	--build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/core/sdk:2.2.105 \
    --build-arg CORECLR_BRANCH=v2.2.3 \
	--network host \
	--build-arg http_proxy=http://127.0.0.1:3128 \
   	--build-arg https_proxy=http://127.0.0.1:3128 \
	.

#!/usr/bin/env bash

docker build \
	--tag 6opuc/lldb-netcore \
	--build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/core/sdk:2.2.207 \
    --build-arg CORECLR_BRANCH=v2.2.8 \
	.

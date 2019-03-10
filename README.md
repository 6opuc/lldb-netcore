# lldb-netcore

## How to build
- netcore 2.0.3:
```
docker build \
	--tag lldb-netcore:2.0.3 \
	--build-arg BASE_IMAGE=microsoft/dotnet:2.0.3-sdk \
	--build-arg CORECLR_BRANCH=release/2.0.0 \
	--build-arg LLDB_PACKAGE_NAME=lldb-4.0 \
	--build-arg LLDB_BINARY_PATH=lldb-4.0 \
	.
```

## How to use
- netcore 2.0.3:
```
docker run -it -v /stripe/upload/coredump:/tmp/coredump lldb-netcore:2.0.3
```

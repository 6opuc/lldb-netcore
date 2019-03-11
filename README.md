# lldb-netcore
Docker image with lldb debugger and SOS plugin, compiled from sources with lldb headers.
By default loads process coredump from /tmp/coredump, loads SOS plugin and prints current exception, leaving lldb shell open.

## How to build
### netcore 2.0.3:
```bash
docker build \
	--tag 6opuc/lldb-netcore:2.0.3 \
	--build-arg BASE_IMAGE=microsoft/dotnet:2.0.3-sdk \
	--build-arg CORECLR_BRANCH=release/2.0.0 \
	--build-arg LLDB_PACKAGE_NAME=lldb-4.0 \
	--build-arg LLDB_BINARY_PATH=lldb-4.0 \
	.
```
- BASE_IMAGE - Base image of dotnet sdk. Used both at build time and runtime.
- CORECLR_BRANCH - coreclr repository(https://github.com/dotnet/coreclr.git) branch to build SOS plugin from
- LLDB_PACKAGE_NAME - Package name of lldb debugger in base image
- LLDB_BINARY_PATH - Path to binary with lldb debugger after package installation

## How to use
### netcore 2.0.3:
```bash
docker run -it -v /stripe/upload/coredump:/tmp/coredump 6opuc/lldb-netcore:2.0.3
```
- /stripe/upload/coredump - Path to coredump of crashed process on docker host machine

## Usecases
### Container crashed

1. Copy crashed process working directory(coredump is automatically created in crashed process working directory):
```bash
docker cp 79686a7aff63:/app /tmp
```
- 79686a7aff63 - id of container with crashed process
- /app - crashed process working directory inside container filesystem

2. Find crashed process coredump:
```bash
ls /tmp/app/core.*
```
example output:
```
/tmp/app/core.26939
```

3. Open coredump with debugger:
```bash
docker run -it -v /tmp/app/core.26939:/tmp/coredump 6opuc/lldb-netcore:2.0.3
```
example output:
```
(lldb) target create "/usr/bin/dotnet" --core "/tmp/coredump"
Core file '/tmp/coredump' (x86_64) was loaded.
(lldb) plugin load /coreclr/libsosplugin.so
(lldb) sos PrintException
Exception object: 00007f3fb001ce08
Exception type:   System.NullReferenceException
Message:          Object reference not set to an instance of an object.
InnerException:   <none>
StackTrace (generated):
    SP               IP               Function
    00007FFCE0A312F0 00007F3FD7940481 test.dll!test.Program.Main(System.String[])+0x1

StackTraceString: <none>
HResult: 80004003
(lldb)
```

4. Continue exploring coredump in lldb shell:
```
help
```

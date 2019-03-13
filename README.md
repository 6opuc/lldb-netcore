# lldb-netcore
Docker image with lldb debugger and SOS plugin, compiled from sources with lldb headers.
By default loads process coredump from /tmp/coredump, loads SOS plugin and prints current exception, leaving lldb shell open.
Image tag matches dotnet runtime version.

## How to use
```bash
docker run --rm -it -v /stripe/upload/coredump:/tmp/coredump 6opuc/lldb-netcore
```
- /stripe/upload/coredump - Path to coredump of crashed process on docker host machine

## Usecases
### Container crashed

1. Copy crashed process working directory(coredump is automatically created in crashed process working directory) to temporary directory on host:
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
docker run --rm -it -v /tmp/app/core.26939:/tmp/coredump 6opuc/lldb-netcore
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

### Analyze running container
1. Get id of docker container(docker ps) you need to analyze. In this example it is "b5063ef5787c"

2. Run container with createdump utility(it needs sys_admin and sys_ptrace privileges. If your running container already has these privileges you can attach to running container and run createdump utility from there):
```bash
docker run --rm -it --cap-add sys_admin --cap-add sys_ptrace --net=container:b5063ef5787c --pid=container:b5063ef5787c -v /tmp:/tmp 6opuc/lldb-netcore /bin/bash
```
- b5063ef5787c - id of container you need to analyze
- /tmp - temporary directory on host, where coredump will be created

3. Find PID of dotnet process you need to analyze:
```bash
ps aux
```
In this example PID is "7"

4. Create coredump of dotnet process and exit from container:
```bash
createdump -u -f /tmp/coredump 7
exit
```
- 7 is dotnet process PID

5. Open coredump with debugger:
```bash
docker run --rm -it -v /tmp/coredump:/tmp/coredump 6opuc/lldb-netcore
```
example output:
```
(lldb) target create "/usr/bin/dotnet" --core "/tmp/coredump"
Core file '/tmp/coredump' (x86_64) was loaded.
(lldb) plugin load /coreclr/libsosplugin.so
(lldb) sos PrintException
There is no current managed exception on this thread
(lldb)
```

6. Continue exploring coredump in lldb shell:
```
help
```

## How to build
### netcore 2.2.3:
```bash
docker build \
	--tag 6opuc/lldb-netcore:2.2.3 \
   	--build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/core/sdk:2.2.105 \
   	--build-arg CORECLR_BRANCH=v2.2.3 \
	.
```
### netcore 2.2.2:
```bash
docker build \
	--tag 6opuc/lldb-netcore:2.2.2 \
   	--build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/core/sdk:2.2.104 \
   	--build-arg CORECLR_BRANCH=v2.2.2 \
	.
```
### netcore 2.1.8:
```bash
docker build \
	--tag 6opuc/lldb-netcore:2.1.8 \
	--build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/core/sdk:2.1.504 \
   	--build-arg CORECLR_BRANCH=v2.1.8 \
	.
```
### netcore 2.0.3:
```
docker build \
	--tag 6opuc/lldb-netcore:2.0.3 \
	--build-arg BASE_IMAGE=microsoft/dotnet:2.0.3-sdk \
	--build-arg CORECLR_BRANCH=v2.0.3 \
	.
```
- BASE_IMAGE - Base image of dotnet sdk. Used both at build time and runtime.
- CORECLR_BRANCH - coreclr repository(https://github.com/dotnet/coreclr.git) branch/tag to build SOS plugin from

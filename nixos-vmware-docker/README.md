# NixOS VMWare Docker agent
My work dev machine is a VMWare VM, which cannot run alongside Hyper-V or WSL.

This config sets up NixOS to serve as a docker build agent.

```
docker context create vmware-docker --docker "host=ssh://vmware-docker"

docker context use vmware-docker
```

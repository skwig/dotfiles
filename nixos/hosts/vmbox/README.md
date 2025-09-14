https://gist.github.com/peppergrayxyz/fdc9042760273d137dddd3e97034385f
```sh
qemu-system-x86_64                                               \
    -enable-kvm                                                  \
    -M q35                                                       \
    -smp 4                                                       \
    -m 4G                                                        \
    -cpu host                                                    \
    -net nic,model=virtio                                        \
    -net user,hostfwd=tcp::2222-:22                              \
    -device virtio-vga-gl,hostmem=4G,blob=true,venus=true        \
    -vga none                                                    \
    -display gtk,gl=on,show-cursor=on                            \
    -usb -device usb-tablet                                      \
    -object memory-backend-memfd,id=mem1,size=4G                 \
    -machine memory-backend=mem1                                 \
    -hda nixos.qcow2                                                    \
    -cdrom /mnt/Storage/iso/nixos-graphical-25.05.805252.b43c397f6c21-x86_64-linux.iso
```

## Working multimonitor
```
[nix-shell:~]$ sudo dmesg | grep drm
[    0.432191] ACPI: bus type drm_connector registered
[    0.637862] [drm] pci: virtio-vga detected at 0000:07:00.0
[    0.646017] [drm] features: +virgl +edid -resource_blob -host_visible
[    0.646018] [drm] features: +context_init
[    0.646708] [drm] number of scanouts: 2
[    0.646713] [drm] number of cap sets: 2
[    0.651721] [drm] cap set 0: id 1, max-version 1, max-size 308
[    0.651773] [drm] cap set 1: id 2, max-version 2, max-size 1408
[    0.652113] virtio-pci 0000:07:00.0: [drm] Registered 2 planes with drm panic
[    0.652116] [drm] Initialized virtio_gpu 0.1.0 for 0000:07:00.0 on minor 0
[    0.654645] fbcon: virtio_gpudrmfb (fb0) is primary device
[    0.680843] virtio-pci 0000:07:00.0: [drm] fb0: virtio_gpudrmfb frame buffer device
[    2.007298] systemd[1]: Starting Load Kernel Module drm...
[    2.021301] systemd[1]: modprobe@drm.service: Deactivated successfully.
[    2.021479] systemd[1]: Finished Load Kernel Module drm.

```

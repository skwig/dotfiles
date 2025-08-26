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

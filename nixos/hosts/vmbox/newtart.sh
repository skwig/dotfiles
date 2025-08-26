qemu-system-x86_64                                                                         \
    -enable-kvm                                                                            \
    -M q35,accel=kvm,usb=off                                                               \
    -smp 16                                                                                \
    -m 32G                                                                                 \
    -cpu host                                                                              \
    -net nic,model=virtio                                             \
    -net user,hostfwd=tcp::2222-:22                                             \
    -device virtio-vga-gl,hostmem=32G,blob=true,venus=true                                  \
    -vga none                                                                              \
    -display gtk,gl=on                                                                     \
    -object memory-backend-memfd,id=mem1,size=32G                                          \
    -machine memory-backend=mem1                                                           \
    -hda nixos.qcow2                                                                       \
    -cdrom /mnt/Storage/iso/nixos-graphical-25.05.805252.b43c397f6c21-x86_64-linux.iso     \
    -device qemu-xhci,id=xhci                                                              \
    -device virtio-mouse-pci -device virtio-keyboard-pci

    # -device usb-host,vendorid=0x09da,productid=0x72b2
#     -device '{"driver":"pcie-root-port","port":16,"chassis":1,"id":"pci.1","bus":"pcie.0","multifunction":true,"addr":"0x2"}' \
# -device '{"driver":"pcie-root-port","port":17,"chassis":2,"id":"pci.2","bus":"pcie.0","addr":"0x2.0x1"}' \
#     -device '{"driver":"qemu-xhci","p2":15,"p3":15,"id":"usb","bus":"pci.2","addr":"0x0"}' \
#     -device '{"driver":"usb-host","hostdevice":"/dev/bus/usb/003/008","id":"hostdev0","bus":"usb.0","port":"2"}'
#
    # -netdev bridge,id=net0,br=virbr0 \

# dotfiles

# NixOs
## Bootstrapping
### vGPU
```
nix-store --add-fixed sha256 ~/Downloads/NVIDIA-GRID-Linux-KVM-550.90.05-550.90.07-552.74.zip
```
```
UUID=6ece0115-ff26-4bd0-958e-9ee30cf22fe7
PCI_ADDRESS=01:00.0

sudo mdevctl start -u $UUID -p 0000:$PCI_ADDRESS -t nvidia-334
sudo mdevctl define -a -u $UUID
```

## Installing
```sh
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#blackbox
```

## Credits
Nix config inspired by [vasujain275](https://github.com/vasujain275/rudra)
https://github.com/Cybersnake223/Hypr

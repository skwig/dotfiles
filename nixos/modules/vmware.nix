{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:

let
  kernel = pkgs.linuxPackagesFor config.boot.kernelPackages.kernel;

  vmwareMod = kernel.vmware or kernel.vmware-modules-workstation;
in
{
  # https://support.broadcom.com/group/ecx/productdownloads?subfamily=VMware%20Workstation%20Pro&freeDownloads=true
  # nix-store --add-fixed sha256 ~/Downloads/VMware-Workstation-Full-17.6.4-24832109.x86_64.bundle
  virtualisation.vmware.host.enable = true;
  virtualisation.vmware.host.package = pkgs.vmware-workstation;

  # manual patch, because 25.05 is broken with kernels > 6.15
  boot.extraModulePackages = lib.mkForce [ vmwareMod ];
}

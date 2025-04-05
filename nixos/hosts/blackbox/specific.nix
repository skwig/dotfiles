# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "blackbox";
  networking.networkmanager.enable = true;

  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.vgpu_17_3;
  };
  hardware.nvidia.vgpu.patcher.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["skwig"];

  boot.extraModprobeConfig = "options kvm_amd nested=1";
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };

    # spiceUSBRedirection.enable = true;
  };

  programs.steam.enable = true;

  environment.systemPackages = with pkgs; [
    nvtop

    vscodium

    chromium
    firefox
    brave

    discord

    mesa-demos
  ];
}

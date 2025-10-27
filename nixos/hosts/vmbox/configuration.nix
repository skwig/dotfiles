{
  config,
  pkgs,
  pkgs-pr,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/hyprland.nix
    # ../../modules/kde.nix
    ../../modules/dev.nix
    ../../modules/dev-dotnet.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_16;

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true;

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    pciutils
    virglrenderer
  ];

  services.qemuGuest.enable = true;
  services.qemuGuest.package = pkgs-unstable.qemu_kvm.ga;
  services.spice-vdagentd.enable = true;
}

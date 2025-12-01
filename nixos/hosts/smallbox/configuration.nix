{
  config,
  pkgs,
  pkgs-unstable,
  username,
  hostname,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/bluetooth.nix
    ../../modules/amd.nix
    # ../../modules/nvidia.nix
    ../../modules/hyprland.nix
    # ../../modules/kde.nix
    ../../modules/personal.nix
    ../../modules/libvirt.nix
    ../../modules/vmware.nix
    # ../../modules/openssh.nix
    # ../../modules/wayvnc.nix
    ../../modules/dev.nix
    ../../modules/dev-ai.nix
    ../../modules/dev-az.nix
    ../../modules/dev-dotnet.nix
    # ../../modules/dev-embedded.nix
    ../../modules/dev-go.nix
    ../../modules/dev-k8s.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_15;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # services.printing.enable = true;

  # services.fprintd.enable = true;

  environment.systemPackages = with pkgs; [
    impala
    moonlight-qt
  ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  services.fprintd = {
    enable = true;
  };

  security.pam.services = {
    greetd = {
      fprintAuth = true;
      unixAuth = true;
    };
    sudo = {
      fprintAuth = false;
      unixAuth = true;
    };
  };

  services.cloudflare-warp = {
    enable = true;
  };
}

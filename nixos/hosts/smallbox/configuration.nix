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
    ../../modules/hyprland.nix
    ../../modules/personal.nix
    ../../modules/dev.nix
    ../../modules/dev-dotnet.nix
    ../../modules/dev-az.nix
    ../../modules/dev-k8s.nix
    ../../modules/dev-go.nix
    ../../modules/dev-embedded.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Bratislava";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sk_SK.UTF-8";
    LC_IDENTIFICATION = "sk_SK.UTF-8";
    LC_MEASUREMENT = "sk_SK.UTF-8";
    LC_MONETARY = "sk_SK.UTF-8";
    LC_NAME = "sk_SK.UTF-8";
    LC_NUMERIC = "sk_SK.UTF-8";
    LC_PAPER = "sk_SK.UTF-8";
    LC_TELEPHONE = "sk_SK.UTF-8";
    LC_TIME = "sk_SK.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # services.printing.enable = true;

  # services.fprintd.enable = true;

  environment.systemPackages = with pkgs; [
    remmina
  ];

  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  services.cloudflare-warp = {
    enable = true;
  };
}

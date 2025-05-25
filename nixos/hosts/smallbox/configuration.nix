{
  config,
  pkgs,
  pkgs-unstable,
  username,
  hostname,
  ...
}:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";
    sha256 = "1iqfq5lz3102cp3ryqqqs2hr2bdmwn0mdajprh1ls5h5nsfkigs1";
  };
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # Bootloader.
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

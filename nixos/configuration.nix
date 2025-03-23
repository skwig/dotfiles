# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
        ./modules/desktop.nix
        ./modules/user.nix
        ./modules/dev.nix
        ./modules/dev.dotnet.nix
        ./modules/dev.go.nix
        ./hosts/blackbox/hardware-configuration.nix
  ];
  # Bootloader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda";
  # boot.loader.grub.useOSProber = true;
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    lf
    wget

    chromium
    firefox

    discord

    fastfetch
    coreutils 
    unzip
  ];

  fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "JetBrainsMono"]; }) ];

  # virtualisation.vmware.guest.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  system.stateVersion = "24.11";
}

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

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

  users.users.skwig = {
    isNormalUser = true;
    description = "skwig";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.zsh.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    lf
    wget

    # Desktop
    hyprland
    hyprlock
    hyprshot
    waybar
    rofi-wayland
    greetd.tuigreet
    cliphist
    dunst
    foot
    alacritty

    chromium
    firefox

    fastfetch
    coreutils 
    neovim git gh lazygit gcc gnumake cmake fzf ripgrep cargo
    stow
  ];

  fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "JetBrainsMono"]; }) ];

  virtualisation.vmware.guest.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd Hyprland";
      };
    };
  };

  services.logind = {
    extraConfig = ''
      HandlePowerKey=suspend
    '';
  };

  programs.hyprland.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  system.stateVersion = "24.11";
}

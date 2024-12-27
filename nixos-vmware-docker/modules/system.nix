# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos-vmware-docker";

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

  users.users.dockeragent = {
    isNormalUser = true;
    description = "dockeragent";
    shell = pkgs.bash;
    extraGroups = [ "networkmanager" "wheel" "docker"];
  };

  environment.systemPackages = with pkgs; [
    neovim
    docker
    lazydocker
  ];

  virtualisation.docker = {
    enable = true;
  };
  virtualisation.vmware.guest.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # services.getty.autologinUser = "dockeragent";
  services.openssh.enable = true;

  system.stateVersion = "24.11";
}

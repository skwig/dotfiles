# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    lf
    wget

    fastfetch
    coreutils 
    unzip

    nnn

    brave
    wezterm
  ];

  fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "JetBrainsMono"]; }) ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.zsh.enable = true;

  system.stateVersion = "24.11";
}

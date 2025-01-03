# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim

    git 
    gh 
    lazygit 

    docker
    lazydocker

    gcc 
    gnumake 
    cmake 

    fzf 
    ripgrep 

    cargo
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  virtualisation.docker = {
    enable = true;
  };
}

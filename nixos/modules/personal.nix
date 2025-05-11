{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    discord
    spotify
    mpv
    vlc
    synology-drive-client
    pkgs-unstable.bolt-launcher
  ];

  programs.steam.enable = true;
}

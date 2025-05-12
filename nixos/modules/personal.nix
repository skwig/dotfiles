{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    discord
    spotify
    mpv
    vlc
    synology-drive-client
    pkgs-unstable.bolt-launcher
    lutris
    wine-wayland
  ];

  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];
}

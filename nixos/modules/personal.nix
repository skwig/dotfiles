{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    discord
    spotify
    mpv
    vlc
    synology-drive-client
  ];

  programs.steam.enable = true;
}

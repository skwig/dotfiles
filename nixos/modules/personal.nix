{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ discord spotify mpv vlc ];

  programs.steam.enable = true;
}

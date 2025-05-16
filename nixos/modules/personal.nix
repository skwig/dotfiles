{
  pkgs,
  pkgs-unstable,
  fonts,
  ...
}:

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
    qbittorrent
    pywal16
  ];

  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];
}

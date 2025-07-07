{
  pkgs,
  pkgs-unstable,
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
    gimp
    gamescope
    syncplay
    obsidian
  ];

  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];
  # programs.steam.gamescopeSession = true;

  # ln -s ~/runelite ~/.local/share/bolt-launcher/.runelite
}

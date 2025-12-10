{
  pkgs,
  pkgs-unstable,
  username,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    discord
    pkgs-unstable.webcord
    spotify
    mpv
    vlc
    yt-dlp
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
    gnome-disk-utility
    signal-desktop
    bitwarden-desktop
    remmina
    prismlauncher
  ];

  programs.steam.enable = true;
  programs.steam.extraCompatPackages = with pkgs; [ proton-ge-bin ];
  # programs.steam.gamescopeSession = true;

  # ln -s ~/runelite ~/.local/share/bolt-launcher/.runelite

  environment.sessionVariables = {
    SSH_AUTH_SOCK = "/home/${username}/.bitwarden-ssh-agent.sock";
  };
}

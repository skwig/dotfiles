{ config, pkgs, ... }:

{

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nix-search-cli

    coreutils
    file
    fastfetch
    wget
    htop
    zip

    yazi
    imagemagick
    oh-my-posh

    # TMP
    gum
    eza
    pywal
    sway
    swaynotificationcenter
    grimblast
    libnotify

    # TODO: Some sort of "desktop" section? These dont work in TTY or headless mode
    networkmanagerapplet
    efibootmgr

    brave
    google-chrome
    wezterm
    dolphin
    vscodium
  ];

  fonts.packages = with pkgs; [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];
  time.hardwareClockInLocalTime = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
  };

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "sudo"
        "kubectl"
        "web-search"
        "fzf"
      ];
    };
    syntaxHighlighting = {
      enable = true;
    };
  };

  system.stateVersion = "24.11";
}

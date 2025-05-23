{
  config,
  pkgs,
  pkgs-unstable,
  ...
}:

{

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nix-search-cli

    coreutils
    file
    fastfetch
    wget
    htop
    zip
    killall

    yazi
    imagemagick
    oh-my-posh

    # TMP
    eza
    pywal
    libnotify

    # TODO: Some sort of "desktop" section? These dont work in TTY or headless mode
    networkmanagerapplet
    efibootmgr

    brave
    pkgs-unstable.google-chrome
    wezterm
    nautilus
    vscodium
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    twemoji-color-font
    twitter-color-emoji
  ];
  fonts.fontconfig = {
    enable = true;
    defaultFonts.emoji = [
      "Twitter Color Emoji"
    ];
  };

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

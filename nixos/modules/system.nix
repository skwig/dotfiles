{
  config,
  pkgs,
  pkgs-unstable,
  username,
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

  home-manager.users.${username} =
    { config, ... }:
    let
      dotfiles = /home/${username}/dotfiles;
    in
    {
      home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/zsh/.zshrc;
      home.file.".ideavimrc".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/ideavim/.ideavimrc;
      home.file.".Xresources".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/Xresources/.Xresources;

      home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/nvim;
      home.file.".config/hypr".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/hypr;
      home.file.".config/rofi".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/rofi;
      home.file.".config/waybar".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/waybar;
      home.file.".config/gtk-3.0".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/gtk-3.0;
      home.file.".config/gtk-4.0".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/gtk-4.0;
      home.file.".config/hyprpanel".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/hyprpanel;
      home.file.".config/wezterm".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/wezterm;
      home.file.".config/wlogout".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/wlogout;

      home.file.".config/JetBrains/Rider2024.3/rider64.vmoptions".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/wayland/rider64.vmoptions;

      home.stateVersion = "24.11";
    };
  system.stateVersion = "24.11";
}

{
  lib,
  pkgs,
  pkgs-unstable,
  pkgs-24,
  username,
  allowUnfreePredicate,
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

  # nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = allowUnfreePredicate;

  environment.localBinInPath = true;

  environment.systemPackages = with pkgs; [
    coreutils
    file
    fastfetch
    wget
    htop
    btop
    zip
    unzip
    socat

    nvtopPackages.amd

    yazi
    oh-my-posh
    imagemagick
    ncdu

    # TODO: Some sort of "desktop" section? These dont work in TTY or headless mode
    imagemagick
    efibootmgr
    file-roller

    brave
    chromium
    google-chrome
    wezterm
    xterm
    nautilus
    vscodium
  ];

  fonts = {
    fontconfig = {
      enable = true;
      defaultFonts.emoji = [
        "Twitter Color Emoji"
      ];
    };

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      twemoji-color-font
      twitter-color-emoji
    ];
  };

  time.hardwareClockInLocalTime = true;
  time.timeZone = "Europe/Bratislava";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sk_SK.UTF-8";
    LC_IDENTIFICATION = "sk_SK.UTF-8";
    LC_MEASUREMENT = "sk_SK.UTF-8";
    LC_MONETARY = "sk_SK.UTF-8";
    LC_NAME = "sk_SK.UTF-8";
    LC_NUMERIC = "sk_SK.UTF-8";
    LC_PAPER = "sk_SK.UTF-8";
    LC_TELEPHONE = "sk_SK.UTF-8";
    LC_TIME = "sk_SK.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
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

  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "dialout"
    ];
  };

  environment.sessionVariables = {
    TERMINAL = "wezterm";
    BROWSER = "brave";
  };

  xdg.mime.defaultApplications = {
    "application/pdf" = "brave-browser.desktop";
    "text/plain" = "codium.desktop";
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

      home.file.".config/sunshine/sunshine.conf".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/sunshine/sunshine.conf;

      home.file.".config/JetBrains/Rider2025.3/rider64.vmoptions".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/wayland/rider64.vmoptions;

      home.file.".local/bin/dots-browser".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/dots-browser.sh;
      home.file.".local/bin/dots-cliphist".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/dots-cliphist.sh;
      home.file.".local/bin/dots-launcher".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/dots-launcher.sh;
      home.file.".local/bin/dots-rider-fzf".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/dots-rider-fzf.sh;
      home.file.".local/bin/dots-rider-picker".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/dots-rider-picker.sh;
      home.file.".local/bin/dots-script-picker".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/dots-script-picker.sh;
      home.file.".local/bin/dots-start".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/dots-start.sh;
      home.file.".local/bin/dots-terminal".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/dots-terminal.sh;
      home.file.".local/bin/gaming".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/gaming.sh;
      home.file.".local/bin/setup-git".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/setup-git.sh;
      home.file.".local/bin/vm-submap-on-vm-focus".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/vm-submap-on-vm-focus.sh;

      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };

      home.stateVersion = "24.11";
    };

  home-manager.backupFileExtension = "backup";

  system.stateVersion = "24.11";
}

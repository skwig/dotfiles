{ config, pkgs, ... }:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    nix-search-cli

    coreutils
    fastfetch
    wget
    htop
    zip

    yazi
    imagemagick

    # TMP
    gum
    eza
    pywal
    oh-my-posh
    sway
    swaynotificationcenter
    grimblast
    libnotify

    # TODO: Some sort of "desktop" section? These dont work in TTY or headless mode
    networkmanagerapplet

    brave
    wezterm
    dolphin
    vscodium
  ];

  fonts.packages = with pkgs;
    [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];
  time.hardwareClockInLocalTime = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.zsh.enable = true;

  system.stateVersion = "24.11";
}

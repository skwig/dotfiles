{
  pkgs,
  username,
  hostname,
  dotfiles,
  allowUnfreePredicate,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/openssh.nix
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # --- From system.nix START ---
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
    # From system.nix
    coreutils
    file
    fastfetch
    wget
    btop
    zip
    unzip

    yazi
    oh-my-posh
    ncdu

    # From dev.nix
    nixd
    nixfmt
    git
    git-lfs
    gh
    lazygit
    lazydocker
    just
    fzf
    ripgrep
    fd
    jq

    # Own
    wakeonlan
  ];

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

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [
        "sudo"
        "fzf"
      ];
    };
    syntaxHighlighting = {
      enable = true;
    };
  };

  programs.nh = {
    enable = true;
    flake = "/${dotfiles}/nixos/";
  };

  services.udisks2.enable = true;

  home-manager.users.${username} =
    { config, ... }:
    {
      home.file.".zshrc".source = config.lib.file.mkOutOfStoreSymlink /${dotfiles}/zsh/.zshrc;

      home.file.".local/bin/wake-blackbox".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/bin/wake-blackbox.sh;

      home.stateVersion = "26.05";
    };

  home-manager.backupFileExtension = "backup";

  # --- From system.nix END ---

  # --- From dev.nix END ---
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  virtualisation.docker = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # --- From dev.nix END ---

  system.stateVersion = "26.05";
}

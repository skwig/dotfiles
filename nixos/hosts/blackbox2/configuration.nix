{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "blackbox2";
  networking.networkmanager.enable = true;

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

  users.users.mbr = {
    isNormalUser = true;
    description = "mbr";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs;
      [
        #  thunderbird
      ];
  };

  system.activationScripts.symlink = {
    text = ''
      mkdir -p ~/.config/

      ln -sf -t /home/mbr/.config/ /home/mbr/dotfiles/nvim/
      chown -h mbr:users /home/mbr/.config/nvim

      ln -sf -t /home/mbr/.config/ /home/mbr/dotfiles/hypr/
      chown -h mbr:users /home/mbr/.config/hypr

      ln -sf -t /home/mbr/.config/ /home/mbr/dotfiles/waybar/
      chown -h mbr:users /home/mbr/.config/waybar

      ln -sf -t /home/mbr/.config/ /home/mbr/dotfiles/wezterm/
      chown -h mbr:users /home/mbr/.config/wezterm

      ln -sf -t /home/mbr/.config/ /home/mbr/dotfiles/wlogout/
      chown -h mbr:users /home/mbr/.config/wlogout

      ln -sf -t /home/mbr/.config/ /home/mbr/dotfiles/gtk-3.0/
      chown -h mbr:users /home/mbr/.config/gtk-3.0

      ln -sf -t /home/mbr/.config/ /home/mbr/dotfiles/gtk-4.0/
      chown -h mbr:users /home/mbr/.config/gtk-4.0

      ln -sf -t /home/mbr/ /home/mbr/dotfiles/Xresources/.Xresources
      chown -h mbr:users /home/mbr/.Xresources

      ln -sf -t /home/mbr/ /home/mbr/dotfiles/ideavim/.ideavimrc
      chown -h mbr:users /home/mbr/.ideavimrc
    '';
  };

  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    google-chrome
    git-credential-manager
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config.credential.credentialStore = "secretservice";
    config.credential.helper = "manager";
  };
}

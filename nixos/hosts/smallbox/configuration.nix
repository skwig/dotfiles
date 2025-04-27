{ config, pkgs, ... }:

{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "smallbox";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
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

  # services.printing.enable = true;

  users.users.skwig = {
    isNormalUser = true;
    description = "skwig";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # TODO: Better way? home manager?
  system.activationScripts.symlink = {
    text = ''
      mkdir -p ~/.config/

      ln -sf -t /home/skwig/.config/ /home/skwig/dotfiles/nvim/
      chown -h skwig:users /home/skwig/.config/nvim

      ln -sf -t /home/skwig/.config/ /home/skwig/dotfiles/hypr/
      chown -h skwig:users /home/skwig/.config/hypr

      ln -sf -t /home/skwig/.config/ /home/skwig/dotfiles/waybar/
      chown -h skwig:users /home/skwig/.config/waybar

      ln -sf -t /home/skwig/.config/ /home/skwig/dotfiles/wezterm/
      chown -h skwig:users /home/skwig/.config/wezterm

      ln -sf -t /home/skwig/.config/ /home/skwig/dotfiles/wlogout/
      chown -h skwig:users /home/skwig/.config/wlogout

      ln -sf -t /home/skwig/.config/ /home/skwig/dotfiles/gtk-3.0/
      chown -h skwig:users /home/skwig/.config/gtk-3.0

      ln -sf -t /home/skwig/.config/ /home/skwig/dotfiles/gtk-4.0/
      chown -h skwig:users /home/skwig/.config/gtk-4.0

      ln -sf -t /home/skwig/ /home/skwig/dotfiles/Xresources/.Xresources
      chown -h skwig:users /home/skwig/.Xresources

      ln -sf -t /home/skwig/ /home/skwig/dotfiles/ideavim/.ideavimrc
      chown -h skwig:users /home/skwig/.ideavimrc
    '';
  };

  # services.fprintd.enable = true;

  services.cloudflare-warp = { enable = true; };
}

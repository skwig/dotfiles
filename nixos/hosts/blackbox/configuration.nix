{
  config,
  pkgs,
  freelens,
  ...
}:

let
  username = "skwig";
in
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = "blackbox";
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

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = [ username ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };

    # spiceUSBRedirection.enable = true;
  };

  users.users.${username} = {
    isNormalUser = true;
    description = username;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };

  services.gnome.gnome-keyring.enable = true;

  system.activationScripts.symlink = {
    text = ''
      mkdir -p ~/.config/

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/nvim/
      chown -h ${username}:users /home/${username}/.config/nvim

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/hypr/
      chown -h ${username}:users /home/${username}/.config/hypr

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/waybar/
      chown -h ${username}:users /home/${username}/.config/waybar

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/wezterm/
      chown -h ${username}:users /home/${username}/.config/wezterm

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/wlogout/
      chown -h ${username}:users /home/${username}/.config/wlogout

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/gtk-3.0/
      chown -h ${username}:users /home/${username}/.config/gtk-3.0

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/gtk-4.0/
      chown -h ${username}:users /home/${username}/.config/gtk-4.0

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/rofi/
      chown -h ${username}:users /home/${username}/.config/rofi

      ln -sf -t /home/${username}/.config/ /home/${username}/dotfiles/dunst/
      chown -h ${username}:users /home/${username}/.config/dunst

      ln -sf -t /home/${username}/.config/JetBrains/Rider2024.3/ /home/${username}/dotfiles/wayland/rider64.vmoptions
      chown -h ${username}:users /home/${username}/.config/JetBrains/Rider2024.3/rider64.vmoptions

      ln -sf -t /home/${username}/ /home/${username}/dotfiles/Xresources/.Xresources
      chown -h ${username}:users /home/${username}/.Xresources

      ln -sf -t /home/${username}/ /home/${username}/dotfiles/zsh/.zshrc
      chown -h ${username}:users /home/${username}/.zshrc

      ln -sf -t /home/${username}/ /home/${username}/dotfiles/ideavim/.ideavimrc
      chown -h ${username}:users /home/${username}/.ideavimrc
    '';
  };

  # services.fprintd.enable = true;

  environment.systemPackages = with pkgs; [
    imgcat
    mesa-demos
    python3
    freelens
  ];
}

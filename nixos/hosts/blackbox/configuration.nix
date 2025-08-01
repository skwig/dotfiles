{
  pkgs,
  pkgs-pr,
  username,
  hostname,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system.nix
    ../../modules/bluetooth.nix
    ../../modules/nvidia.nix
    ../../modules/hyprland.nix
    ../../modules/personal.nix
    ../../modules/dev.nix
    ../../modules/dev-dotnet.nix
    ../../modules/dev-az.nix
    ../../modules/dev-k8s.nix
    ../../modules/dev-go.nix
    ../../modules/dev-embedded.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = hostname;
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

  # programs.virt-manager.enable = true;
  #
  # users.groups.libvirtd.members = [ username ];
  #
  # virtualisation.libvirtd = {
  #   enable = true;
  #   qemu = {
  #     package = pkgs.qemu_kvm;
  #     runAsRoot = true;
  #     swtpm.enable = true;
  #     ovmf = {
  #       enable = true;
  #       packages = [
  #         (pkgs.OVMF.override {
  #           secureBoot = true;
  #           tpmSupport = true;
  #         }).fd
  #       ];
  #     };
  #   };
  #
  #   # spiceUSBRedirection.enable = true;
  # };

  # virtualisation.vmware.host.enable = true;
  # virtualisation.vmware.host.package = pkgs-unstable.vmware-workstation;

  hardware.keyboard.zsa.enable = true;

  services.gnome.gnome-keyring.enable = true;

  services.fprintd.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    imgcat
    mesa-demos
    python3
    # vmware-workstation
    pkgs-pr.freelens
  ];
}

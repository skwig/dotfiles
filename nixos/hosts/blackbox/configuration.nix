{
  pkgs,
  pkgs-unstable,
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
    ../../modules/amd.nix
    # ../../modules/nvidia.nix
    ../../modules/hyprland.nix
    # ../../modules/kde.nix
    ../../modules/personal.nix
    ../../modules/libvirt.nix
    ../../modules/vmware.nix
    ../../modules/openssh.nix
    ../../modules/wayvnc.nix
    ../../modules/dev.nix
    ../../modules/dev-ai.nix
    ../../modules/dev-az.nix
    ../../modules/dev-dotnet.nix
    ../../modules/dev-k8s.nix
    ../../modules/dev-go.nix
    ../../modules/dev-embedded.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_6_15;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];

  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;
  networking.interfaces."enp8s0".wakeOnLan = {
    enable = true;
    policy = [ "magic" ];
  };

  hardware.keyboard.zsa.enable = true;

  services.fprintd.enable = true;

  # services.avahi = {
  #   enable = true;
  #   nssmdns4 = true;
  #   openFirewall = true;
  # };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0951", ATTR{idProduct}=="170f", TAG+="uaccess"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="09da", ATTR{idProduct}=="72b2", TAG+="uaccess"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="145f", ATTR{idProduct}=="02e7", TAG+="uaccess"

    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="3142", ATTR{idProduct}=="17a8", TAG+="uaccess"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="046d", ATTR{idProduct}=="c077", TAG+="uaccess"
  '';

  services.sunshine = {
    enable = true;
    autoStart = false;
    openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    imgcat
    mesa-demos
    python3
  ];
}

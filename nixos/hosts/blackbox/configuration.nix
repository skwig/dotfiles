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

  hardware.keyboard.zsa.enable = true;

  services.fprintd.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="0951", ATTR{idProduct}=="170f", TAG+="uaccess"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="09da", ATTR{idProduct}=="72b2", TAG+="uaccess"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="145f", ATTR{idProduct}=="02e7", TAG+="uaccess"

    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="3142", ATTR{idProduct}=="17a8", TAG+="uaccess"
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="046d", ATTR{idProduct}=="c077", TAG+="uaccess"
  '';

  environment.systemPackages = with pkgs; [
    imgcat
    mesa-demos
    python3
    # vmware-workstation
    pkgs-pr.freelens
  ];

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINKBYbvBqHC1HbBgrSXPVc3UDqMjCqjr/k1jqQIpnPJR skwig@blackbox"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfbf7RIFcpdW+9ryqeDoRYEeors8vMRj2ILh+UC66xm skwig@smallbox"
  ];

  services.openssh = {
    enable = true;
    ports = [ 17937 ];
    openFirewall = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [ username ];
    };
  };

  home-manager.users.${username} =
    { config, ... }:
    {
      home.enableNixpkgsReleaseCheck = false;
      services.wayvnc = {
        enable = true;
        autoStart = true;
        settings = {
          address = "localhost";
          port = 5900;
        };
      };
    };
}

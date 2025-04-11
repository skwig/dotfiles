# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

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
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.vgpu_17_3;
  };
  hardware.nvidia.vgpu.patcher.enable = true;
  hardware.nvidia.vgpu.patcher.profileOverrides = {
    "440" = {
      vramAllocation = 3584; # 3.5GiB
      heads = 1;
      display.width = 1920;
      display.height = 1080;
      framerateLimit = 144;
    };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  programs.virt-manager.enable = true;

  users.groups.libvirtd.members = ["skwig"];

  boot.extraModprobeConfig = ''
    options kvm_amd nested=1
    options nvidia vup_swrlwar=1
  '';
    # options nvidia vup_qmode=1 vup_swrlwar=1 vup_sunlock=1 #vup_gspvgpu=1

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [(pkgs.OVMF.override {
          secureBoot = true;
          tpmSupport = true;
        }).fd];
      };
    };

    # spiceUSBRedirection.enable = true;
  };

  virtualisation.kvmfr = {
    enable = true;
    shm = {
      enable = true;
      size = 512;
      user = "skwig";
      group = "qemu-libvirtd";
      mode = "0666";
    };
  };

  programs.steam.enable = true;
  programs.mdevctl = {
    enable = true;
    # mdevs = {
    #   "0000:01:00.0" = {
    #     # win10 vm
    #     "00000000-0000-0000-0000-000000000001".mdev_type = "nvidia-256";
    #   };
    # };
  };

   services.fastapi-dls = {
    enable = true;

    debug = true;                # DEBUG
    # listen.ip = "localhost";      # DLS_URL
    # listen.ip = "192.168.100.7";  # DLS_URL
    # listen.ip = "192.168.122.1";  # DLS_URL
    listen.ip = "0.0.0.0";  # DLS_URL
    listen.port = 9999;           # DLS_PORT
    authTokenExpire = 1;          # TOKEN_EXPIRE_DAYS
    lease.expire = 90;            # LEASE_EXPIRE_DAYS
    lease.renewalPeriod = 0.15;   # LEASE_RENEWAL_PERIOD
    extraOptions = {};
    timezone = null;
  }; 

  environment.systemPackages = with pkgs; [
    looking-glass-client
    nvtopPackages.full

    vscodium

    imgcat

    chromium
    firefox
    brave

    discord

    mesa-demos
  ];
}

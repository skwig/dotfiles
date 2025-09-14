{
  pkgs,
  pkgs-unstable,
  pkgs-pr,
  username,
  ...
}:

{
  programs.virt-manager = {
    enable = true;
    package = pkgs-unstable.virt-manager;
  };

  users.groups.libvirtd.members = [ username ];

  virtualisation.libvirtd = {
    enable = true;
    package = pkgs-unstable.libvirt;
    qemu = {
      package = pkgs-pr.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      # ovmf = {
      #   enable = true;
      #   # packages = [
      #   #   (pkgs.OVMF.override {
      #   #     secureBoot = true;
      #   #     tpmSupport = true;
      #   #   }).fd
      #   # ];
      # };

      verbatimConfig = ''
        cgroup_device_acl = [
          "/dev/null",
          "/dev/full",
          "/dev/zero",
          "/dev/random",
          "/dev/urandom",
          "/dev/ptmx",
          "/dev/kvm",
          "/dev/kqemu",
          "/dev/rtc",
          "/dev/hpet",
          "/dev/vfio/vfio",
          "/dev/kvmfr0"
        ]
      '';
    };
  };

  virtualisation.spiceUSBRedirection = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    pkgs-unstable.virglrenderer
    pkgs-unstable.virt-viewer
  ];
}

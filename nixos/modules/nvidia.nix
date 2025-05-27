{
  config,
  pkgs,
  pkgs-legacy,
  ...
}:

{
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    #   version = "565.77";
    #   sha256_64bit = "sha256-CnqnQsRrzzTXZpgkAtF7PbH9s7wbiTRNcM0SPByzFHw=";
    #   sha256_aarch64 = "sha256-LSAYUnhfnK3rcuPe1dixOwAujSof19kNOfdRHE7bToE=";
    #   openSha256 = "sha256-Fxo0t61KQDs71YA8u7arY+503wkAc1foaa51vi2Pl5I=";
    #   settingsSha256 = "sha256-VUetj3LlOSz/LB+DDfMCN34uA4bNTTpjDrb6C6Iwukk=";
    #   persistencedSha256 = "sha256-wnDjC099D8d9NJSp9D0CbsL+vfHXyJFYYgU3CwcqKww=";
    #   patches = [
    #     ./fix-for-linux-6.13.patch
    #   ];
    #   patchesOpen = [
    #     ./nvidia-nv-Convert-symbol-namespace-to-string-literal.patch
    #     ./crypto-Add-fix-for-6.13-Module-compilation.patch
    #     ./Use-linux-aperture.c-for-removing-conflict.patch
    #     ./TTM-fbdev-emulation-for-Linux-6.13.patch
    #   ];
    # };
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  environment.systemPackages = with pkgs; [ nvtopPackages.full ];
}

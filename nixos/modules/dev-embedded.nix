{ pkgs, ... }:

{
  # networking.firewall.allowedTCPPorts = [ 8080 ];

  environment.systemPackages = with pkgs; [
    thonny
    minicom
    picotool
    gcc-arm-embedded

    micropython
  ];

  services.udisks2.enable = true;
}

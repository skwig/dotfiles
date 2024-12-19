# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jetbrains.rider

    (with dotnetCorePackages; combinePackages [
      sdk_8_0_3xx

      # These packages dont work on their own without sdk_8_0_3xx
      dotnet_8.sdk
      dotnet_9.sdk
    ])
  ];
}

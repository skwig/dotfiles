{ pkgs, pkgs-unstable, ... }:

let
  dotnetCombined =
    with pkgs-unstable.dotnetCorePackages;
    combinePackages [
      sdk_10_0
      sdk_9_0_1xx
      sdk_8_0_1xx
      pkgs.dotnetCorePackages.sdk_7_0_3xx
    ];
in
{
  nixpkgs.config.permittedInsecurePackages = [ "dotnet-sdk-7.0.317" ];

  environment.systemPackages = with pkgs; [
    pkgs-unstable.jetbrains.rider
    dotnetCombined
    powershell
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${dotnetCombined}/share/dotnet";
  };
}

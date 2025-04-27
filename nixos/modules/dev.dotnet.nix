{ pkgs, ... }:

let
  dotnetCombined = with pkgs.dotnetCorePackages;
    combinePackages [ sdk_9_0_1xx sdk_8_0_3xx sdk_7_0_3xx ];
in {
  nixpkgs.config.permittedInsecurePackages = [ "dotnet-sdk-7.0.317" ];

  environment.systemPackages = with pkgs; [
    jetbrains.rider
    dotnetCombined
    powershell
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${dotnetCombined}/share/dotnet";
  };
}

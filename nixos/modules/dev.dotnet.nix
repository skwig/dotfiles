{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    jetbrains.rider

    (with dotnetCorePackages;
      combinePackages [
        sdk_8_0_3xx

        # These packages dont work on their own without sdk_8_0_3xx
        dotnet_8.sdk
        dotnet_9.sdk
      ])
  ];
}

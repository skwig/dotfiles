{ pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs-unstable; [
    (azure-cli.withExtensions [ azure-cli-extensions.azure-devops ])
  ];
}

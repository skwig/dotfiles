{ pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs-unstable; [ azure-cli ];
}

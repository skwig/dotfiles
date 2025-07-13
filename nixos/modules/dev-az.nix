{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ azure-cli ];
}

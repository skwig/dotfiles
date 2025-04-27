{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ discord spotify ];

  programs.steam.enable = true;
}

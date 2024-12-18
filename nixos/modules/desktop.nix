# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hyprland
    hyprlock
    hyprshot
    waybar
    rofi-wayland
    greetd.tuigreet
    cliphist
    dunst
    foot
    alacritty
  ];

  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd Hyprland";
      };
    };
  };

  services.logind = {
    extraConfig = ''
      HandlePowerKey=suspend
    '';
  };

}

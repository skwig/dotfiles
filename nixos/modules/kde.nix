{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  # environment.systemPackages = with pkgs; [
  #   hyprland
  #   hyprlock
  #   hyprshot
  #   hypridle
  #   hyprcursor
  #   rose-pine-hyprcursor
  #   waybar
  #   rofi-wayland
  #   greetd.tuigreet
  #   wl-clipboard
  #   cliphist
  #   dunst
  #   foot
  #   alacritty
  #   htop
  # ];
  #
  # environment.sessionVariables = {
  #   NIXOS_OZONE_WL = "1"; # chromium, electron
  #   MOZ_ENABLE_WAYLAND = "1"; # firefox
  # };
  #
  # programs.hyprland.enable = true;
  #
  # services.greetd = {
  #   enable = true;
  #   settings = {
  #     default_session = {
  #       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time --cmd Hyprland";
  #     };
  #   };
  # };
  #
  # services.logind = {
  #   extraConfig = ''
  #     HandlePowerKey=suspend
  #   '';
  # };
}

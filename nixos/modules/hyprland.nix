{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    hyprland
    hyprlock
    hyprshot
    hypridle
    hyprcursor
    hyprpaper
    rose-pine-hyprcursor
    adwaita-icon-theme
    papirus-icon-theme
    waybar
    rofi-wayland
    greetd.tuigreet
    wl-clipboard
    cliphist
    dunst
    brightnessctl
    playerctl
    pavucontrol

    wlogout
    wtype
    hyprpolkitagent
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # chromium, electron
    MOZ_ENABLE_WAYLAND = "1"; # firefox

    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_SCREENSHOTS_DIR = "$HOME/Pictures/screenshots";

    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  xdg.icons.fallbackCursorThemes = [ "Adwaita" ];

  # services.xserver.enable = true;
  # services.displayManager.sddm.enable = true;
  # services.displayManager.sddm.wayland.enable = true;
  # services.displayManager.sddm.enableHidpi = true;

  programs.hyprland.enable = true;
  programs.hyprland.xwayland.enable = true;

  services.printing.enable = true;

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;
  };

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

{
  pkgs,
  pkgs-unstable,
  pkgs-hypr,
  username,
  ...
}:

{
  environment.systemPackages = with pkgs-hypr; [
    hyprls
    hyprshot
    hyprcursor
    hyprpaper
    adwaita-icon-theme
    papirus-icon-theme
    rofi
    wl-clipboard
    cliphist
    brightnessctl
    playerctl
    pavucontrol
    pamixer

    libnotify
    wlogout
    wtype
    pkgs-unstable.hyprpolkitagent

    pkgs-unstable.wayle
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

  #
  # Hyprland
  #

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    package = pkgs-hypr.hyprland;
  };

  programs.uwsm = {
    enable = true;
    package = pkgs-hypr.uwsm;
  };

  #
  # DankMaterialShell
  #
  # Use DMS + Quickshell from nixos-unstable while keeping the
  # NixOS 26.05 module integration.
  #

  programs.dms-shell = {
    enable = true;

    package = pkgs-unstable.dms-shell;

    quickshell.package = pkgs-unstable.quickshell;

    systemd = {
      enable = true;
      target = "graphical-session.target";
      restartIfChanged = true;
    };

    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
  };

  #
  # DMS greeter
  #
  # This configures greetd for us.
  #
  # greetd
  #   -> dms-greeter user
  #   -> temporary pkgs-hypr.hyprland
  #   -> pkgs-unstable.quickshell
  #   -> DMS greeter
  #   -> authenticated Hyprland/UWSM session
  #

  services.displayManager.dms-greeter = {
    enable = true;

    # Explicit for clarity. This would also inherit
    # programs.dms-shell.package.
    package = pkgs-unstable.dms-shell;

    compositor = {
      name = "hyprland";
    };

    # Copy DMS theme/session/wallpaper state into the isolated
    # greeter cache so the login screen matches the desktop.
    configHome = "/home/${username}";

    # Likewise this would inherit programs.dms-shell.quickshell.package,
    # but keeping it explicit makes the unstable package pairing obvious.
    quickshell.package = pkgs-unstable.quickshell;
  };

  #
  # Session / power
  #
  # No services.hypridle here.
  #
  # DMS provides its own lock screen, idle detection, idle inhibitor,
  # auto-lock and suspend handling.
  #

  services.logind = {
    settings = {
      Login = {
        HandlePowerKey = "suspend";
      };
    };
  };

  #
  # Authentication / keyring
  #

  services.gnome.gnome-keyring.enable = true;

  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.polkit-1.enableGnomeKeyring = true;

  #
  # Audio
  #

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;
  };
}

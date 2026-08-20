{
  lib,
  pkgs,
  pkgs-unstable,
  pkgs-hypr,
  pkgs-skwig,
  username,
  ...
}:

{
  environment.systemPackages = with pkgs-unstable; [
    hyprls
    hyprshot
    hyprcursor
    hyprpaper
    adwaita-icon-theme
    papirus-icon-theme
    rofi
    tuigreet
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
    pkgs-skwig.quickshell-skwig-dms
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

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
    package = pkgs-unstable.hyprland;
  };

  systemd.user.services.skwig-dms = {
    description = "Skwig DankMaterialShell";
    path = lib.mkForce [ ]; # inherit session PATH

    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];

    restartIfChanged = true;

    serviceConfig = {
      ExecStart = "${pkgs-skwig.quickshell-skwig-dms}/bin/skwig-dms";
      Restart = "always";
    };
  };

  services.hypridle = {
    enable = true;
    package = pkgs-unstable.hypridle;
  };

  systemd.user.services.hypridle.path = lib.mkForce [ ]; # force inherit session PATH, so skwig-dms is accessible

  programs.uwsm = {
    enable = true;
    package = pkgs-unstable.uwsm;
  };

  # systemd.services.greetd.serviceConfig = {
  #   Type = "idle";
  #   StandardInput = "tty";
  #   StandardOutput = "tty";
  #   StandardErro = "journal";
  #   TTYReset = true;
  #   TTYVHangup = true;
  #   TTYVTDisallocate = true;
  # };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs-unstable.tuigreet}/bin/tuigreet --remember --time --asterisks --cmd 'uwsm start -- hyprland-uwsm.desktop'";
      };
      # initial_session = {
      #   command = "uwsm start hyprland-uwsm.desktop";
      #   user = username;
      # };
      # default_session = initial_session;
    };
    useTextGreeter = true;
  };

  services.logind = {
    settings = {
      Login = {
        HandlePowerKey = "suspend";
      };
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.greetd.enableGnomeKeyring = true;
  # security.pam.services.hyprlock.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  security.pam.services.polkit-1.enableGnomeKeyring = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;
  };
}

{
  lib,
  pkgs,
  pkgs-unstable,
  pkgs-hypr,
  pkgs-pr,
  pkgs-skwig,
  username,
  ...
}:

let
  greeterWallpaper = ../../assets/fuji.jpg;
  greeterColors = ../../assets/fuji.matugen.json;

  runGreeter = pkgs.writeShellScript "run-quickshell-greeter" ''
    export SKWIG_GREETER_USERNAME=${lib.escapeShellArg username}
    export SKWIG_GREETER_DISPLAY_NAME=${lib.escapeShellArg username}
    export SKWIG_GREETER_UWSM=${lib.escapeShellArg "${pkgs-hypr.uwsm}/bin/uwsm"}
    export SKWIG_GREETER_WALLPAPER=${lib.escapeShellArg "${greeterWallpaper}"}
    export SKWIG_GREETER_COLORS=${lib.escapeShellArg "${greeterColors}"}

    ${pkgs-skwig.quickshell-skwig-dms}/bin/skwig-dms-greeter

    # Quickshell exits after Greetd.launch().
    #
    # Kill the temporary greeter compositor so greetd can replace
    # it with the authenticated user's real session.
    ${pkgs.procps}/bin/pkill -x Hyprland
  '';

  greeterHyprlandConfig = pkgs.writeText "greeter-hyprland.conf" ''
    exec-once = ${runGreeter}

    monitor = , preferred, auto, 1

    input {
      kb_layout = us
      follow_mouse = 1
    }

    decoration {
      blur {
        enabled = false
      }
    }

    animations {
      enabled = false
    }

    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
      background_color = 0x111111
      key_press_enables_dpms = true
      mouse_move_enables_dpms = true
    }
  '';
in

{
  environment.systemPackages = with pkgs-hypr; [
    hyprls
    hyprshot
    hyprcursor
    hyprpaper
    adwaita-icon-theme
    papirus-icon-theme
    rofi
    # tuigreet removed: Quickshell is now the greeter
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
    package = pkgs-hypr.hyprland;
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
    package = pkgs-hypr.hypridle;
  };

  systemd.user.services.hypridle.path = lib.mkForce [ ]; # force inherit session PATH, so skwig-dms is accessible

  programs.uwsm = {
    enable = true;
    package = pkgs-hypr.uwsm;
  };

  services.greetd = {
    enable = true;

    settings = {
      default_session = {
        command = "${pkgs-hypr.hyprland}/bin/Hyprland -c ${greeterHyprlandConfig}";

        # No user = "greeter" needed here.
        #
        # The NixOS greetd module defaults default_session.user
        # to the existing "greeter" system account.
      };

      # initial_session = {
      #   command = "uwsm start hyprland-uwsm.desktop";
      #   user = username;
      # };
      # default_session = initial_session;
    };

    # This is now a graphical Wayland greeter, not a TUI.
    useTextGreeter = false;
  };

  # services.greetd already creates the "greeter" system account.
  #
  # This only extends that existing account with a writable home.
  # Outfoxxed does the same because Hyprland wants writable
  # cache/state directories.
  users.users.greeter = {
    home = "/var/lib/greeter";
    createHome = true;
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

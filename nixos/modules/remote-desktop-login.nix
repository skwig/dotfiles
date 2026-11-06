{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  username,
  ...
}:

let
  cfg = config.services.greetd;
  toml = pkgs.formats.toml { };
  stateDir = "/run/desktop-login";

  normalConfig = toml.generate "greetd-normal.toml" cfg.settings;
  remoteConfig = toml.generate "greetd-on-demand.toml" (
    cfg.settings
    // {
      general = (cfg.settings.general or { }) // {
        runfile = "${stateDir}/used";
      };
      initial_session = {
        user = username;
        command = "${lib.getExe pkgs-unstable.uwsm} start -- hyprland-uwsm.desktop";
      };
    }
  );

  runtimeEnv = {
    DESKTOP_LOGIN_STATE_DIR = stateDir;
    DESKTOP_LOGIN_UPTIME_FILE = "/proc/uptime";
  };

  launcher = pkgs.writeShellApplication {
    name = "greetd-launcher";
    runtimeInputs = [ pkgs.coreutils ];
    runtimeEnv = runtimeEnv // {
      GREETD = lib.getExe cfg.package;
      NORMAL_CONFIG = normalConfig;
      REMOTE_CONFIG = remoteConfig;
    };
    text = builtins.readFile ./remote-desktop-login/launcher.sh;
  };

  desktopLogin = pkgs.writeShellApplication {
    name = "desktop-login";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.systemd
      pkgs.util-linux
    ];
    inherit runtimeEnv;
    text = builtins.readFile ./remote-desktop-login/desktop-login.sh;
  };
in
{
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.settings ? initial_session);
        message = "desktop-login requires normal greetd autologin to be disabled.";
      }
    ];

    environment.systemPackages = [ desktopLogin ];
    systemd.tmpfiles.rules = [ "d ${stateDir} 0700 root root -" ];
    systemd.services.greetd.serviceConfig.ExecStart = lib.mkForce (lib.getExe launcher);
  };
}

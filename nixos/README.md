## Useful commands

`https://<team>.cloudflareaccess.com/warp`
`nix flake update nixpkgs-unstable`

## Start the Hyprland desktop over SSH

Hosts importing `modules/hyprland.nix` provide an on-demand login helper after
rebuilding their NixOS configuration:

```sh
ssh -t desktop 'sudo desktop-login'
```

Replace `desktop` with the SSH host. Normal sudo authentication is required; no
passwordless sudo rule is added. The command takes no arguments and starts only
the NixOS configuration's `username` account.

The helper refuses if logind reports an existing Wayland/X11 session, cannot
inspect sessions, or another request is in progress. Otherwise it publishes a
root-only request and restarts greetd. A fixed greetd launcher consumes the
request **before** starting the configured user's Hyprland/UWSM session. Logging
out returns to the existing tuigreet greeter; subsequent greetd starts and normal
boots do not automatically log in.

"Login requested" means the restart was accepted, not that Hyprland or Sunshine
is ready. Connect using Moonlight once the desktop and Sunshine have started.
Sunshine must already be configured to start with the graphical session, and a
usable physical or virtual display output is still required. This helper does
not change Sunshine, firewall rules, SSH configuration, or the GNOME keyring.

### Security and interrupted requests

This is a custom local-session launcher authorized through SSH plus root/sudo,
not a standard greetd remote-login protocol. It is intended for a trusted,
single-user desktop.

- Starting the session exposes an **unlocked physical desktop** until the usual
  session-locking policy locks it. Someone at the monitor can use it.
- No desktop password is supplied or stored, so a password-protected GNOME
  keyring remains locked.
- Checking logind and restarting greetd is not atomic: a local login racing the
  request can still be interrupted. Do not use this as a multi-user login broker.
- `/run/desktop-login` is owned by root with mode `0700`; requests have mode
  `0600` and contain only an expiry time, not credentials. Generated Nix-store
  TOML files are readable configuration, not authorization tokens or secrets.
- Requests expire after at most 15 seconds, using boot-relative uptime rather
  than the wall clock. Expired/malformed requests are consumed without granting
  login. A failed restart removes the request; an abrupt interruption may leave
  one usable until its deadline, **not indefinitely**. Suspend counts toward
  uptime, and reboot clears `/run` entirely.
- The separate `used` runfile may remain until reboot. It prevents a repeated
  initial session and does not grant access. Only a new explicit request resets
  it. No temporary systemd override is created.

To revoke a pending request without stopping an existing session:

```sh
sudo rm -f /run/desktop-login/request
```

For troubleshooting:

```sh
sudo journalctl -u greetd.service -b -n 100
systemctl --user status graphical-session.target sunshine.service
```

Inspect user services as the desktop user; the helper does not confirm streaming
readiness or unlock a locked session. If greetd needs restarting for recovery,
first ensure nobody is using the local desktop: restarting it can end a session.

### Helper tests

From the repository root:

```sh
python3 -m unittest discover -s nixos/tests -p 'test_desktop_login.py' -v
```

These tests run the actual scripts with temporary files and mocked systemd,
logind, privilege reporting and greetd boundaries. They require neither root nor
a running display manager and never restart the machine's greetd service.

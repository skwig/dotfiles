# Hyprland Lua configuration

The literal migration is complete. The current follow-up modernizes shared Lua
behavior for **Hyprland 0.57 or newer**; the installed version at validation is
0.57.2. Package selection remains the existing `pkgs-unstable.hyprland`, without
a dedicated input or exact-version pin.

## Current layout

- `hypr/hyprland.lua`: entrypoint, settings, environment, unchanged startup
  commands, animations, input, and workspace-to-monitor rules.
- `hypr/hyprland.monitors.<host>.lua`: main monitor, shared aliases and scale;
  selected through `.config/hypr-custom/hyprland.monitors.lua` by Home Manager.
- `hypr/hyprland.keybindings.lua`: ordinary/media bindings.
- `hypr/hyprland.keybindings.mainMod.lua`: explicit, individually editable bindings
  instantiated for SUPER+ALT and SUPER, preserving the full 138-binding set.
- `hypr/hyprland.apps.lua`: application/layer rules and one shared todo geometry
  rule. The todo window remains floating, centered, and 1850×1000.
- `hypr/hyprland.events.lua`: shared todo and VM focus callbacks.
- `hypr/hypridle.conf`: unchanged hypridle parser and timeout policy, updated
  compositor-state lock guards.

The eight original compositor `.conf` files are archived byte-for-byte under
`tests/hypr/fixtures/legacy/`, not loaded or deployed. `hypridle.conf` remains
active. User-generated `hypr/dms/` files are not modified by this cleanup.

## Modernized behavior

- **Todo:** one `workspace.created` handler launches the original browser command
  only for a newly created, empty `special:todo`. The exec rule explicitly targets
  that workspace. No deprecated `on_created_empty` rule is registered.
- **VM focus:** native `window.active` handles mapped windows of the exact existing
  QEMU/VMware classes and resets for ordinary/nil/unmapped focus. A closing VM can
  still arrive as an active-window event; its class must not re-enable the VM
  submap after unmapping. Reload does not recompute the current submap, preserving
  manual selection/escape until focus changes. The old Bash/socket watcher and its Home Manager link
  are removed. Its startup entry is obsolete, not moved into a service.
- **Shift+W:** directly dispatches float toggle, then pin toggle in Lua, without
  launching a shell or two hyprctl processes.
- **Lock guards:** the 60-second timeout/resume actions query `hyprctl -j locked`
  and require exactly one JSON value with `locked=true`. They no longer assume a
  `hyprlock` process exists when DMS provides the lock screen. Invalid, empty,
  missing, or unlocked state skips those guarded actions. Other timeouts and
  lock/suspend commands are unchanged.
- **UWSM:** the existing desktop entry/unit already invokes `start-hyprland`, and
  the live compositor has `--watchdog-fd`. The warning-suppression workaround is
  removed; the session launch arrangement is otherwise untouched.

## Startup management: deliberately not implemented

The four remaining startup commands keep their existing startup hook, token
suppression wrapper, shell commands, ampersands, and delay:

1. `wl-paste --watch cliphist store &`
2. `systemctl --user start hyprpolkitagent`
3. `synology-drive &`
4. `sleep 3 && librepods --start-minimized &`

A possible later improvement is to make appropriate programs systemd **user
services**, tied to the graphical session UWSM manages:

- A foreground `ExecStart` replaces `&`; systemd tracks the process, avoids
  duplicate service instances, and can restart it on failure with rate limiting.
- `PartOf=graphical-session.target` can stop the service when the session ends;
  session-start dependencies and environment must be chosen explicitly.
- `systemctl --user status ...` and `journalctl --user -u ...` expose health/logs
  instead of compositor-launched output disappearing into `/dev/null`.
- Clipboard watching is a straightforward candidate. The polkit agent is already
  a user service; only its start trigger would become declarative.
- Synology Drive may fork or manage its own daemon: establish foreground behavior
  before choosing Type/Restart, or a restart loop could result.
- For librepods, replace `sleep 3` only after identifying the real readiness need
  (for example Bluetooth/D-Bus), not by assuming graphical-session ordering means
  every dependency is ready. User and system service ordering are different.

Tradeoffs: more unit definitions, deliberate failure/restart/session semantics,
and NixOS/Home Manager activation for declarative changes. This is lifecycle and
observability work, not a promise of faster startup, and it has not been applied.

## Verification

```sh
bash tests/hypr/run.sh
bash tests/hypr/verify.sh "$(command -v Hyprland)"
```

Tests execute the real Lua against a recording compositor boundary and compare
settings, binding actions/flags, monitors/modes/positions, devices, gestures,
curves, animations, and app rules against independent legacy fixtures, accounting
only for the approved modernization. They exercise shared-variable edits,
callbacks, explicit todo targeting, VM/nil focus, reload synchronization, startup
token suppression, and lock-state guards without starting real processes or
locking/suspending the session. The fake verifier tests version/deprecation policy.

The real >=0.57 verifier must return `config ok` for both host fixtures. It does
not start a compositor or run startup processes. Its socket2-bind diagnostic is
separate from config parsing. The script rejects reported deprecations; executed
registration tests independently reject the removed todo effect. After eventual
deployment/reload, `hyprctl configerrors` and `hyprctl deprecated-config` should
both be empty. Staged verification cannot establish live graphical acceptance.

Staged checks on 2026-11-13 passed: the complete migration suite, both actual
0.57.2 verifier fixtures, and full blackbox/smallbox NixOS builds without a switch.
The legacy fixture contents were checked byte-for-byte against Git originals.
Independent review identified the closing-VM case above; a failing regression
test reproduced it and the mapped-window guard fixes it. An optional test gap
remains: explicit multiple-JSON-value cases for the lock guard's existing
exactly-one-value condition. Live graphical acceptance remains separate.

## Deployment and remaining acceptance

No live reload, system switch, lock, suspend, VM start, merge, or push is part of
staged implementation. Back up out-of-store config/scripts and host links before
deployment. Existing dirty/untracked user work is retained in the isolated worktree.

An already-running Bash VM watcher survives config reload. After deployment,
**log out and back in** to retire it before judging the native handler; do not
leave both implementations competing. Removing the Home Manager helper link
requires the normal NixOS/Home Manager activation.

Then check both modifier sets, VM submap entry/exit/manual escape, todo creation
and reopening, DMS locking/DPMS at the unchanged timeouts, monitor hotplug,
screenshots/privacy/portals, suspend/resume, and reload process counts. vmbox has
no tracked host monitor file and remains excluded pending its deployment audit.

Rollback must restore both the old generation and saved **out-of-store** files;
a NixOS generation alone does not restore the live-linked dotfiles directory.

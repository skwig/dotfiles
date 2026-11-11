# Hyprland modernization after the literal port

User approved all listed improvements **except startup management**, then asked
for an explanation of startup management. No pushing or live activation.

## Approach

Use native Lua events and small binding loops instead of retaining shell/IPC
workarounds. Preserve both modifier sets, all app commands, monitor aliases,
geometry, animation timings, workspace placement, and existing service ownership.
Keeping the old watcher and deprecated todo rule would not accomplish the request.

## Changes

- Define the todo float/size/center rule once in apps.lua. Register one
  workspace.created handler checking addressable_name and is_empty, launching
  the original browser command with an explicit special:todo exec workspace.
- Replace the VM socket watcher with window.active; reset for ordinary/nil focus,
  select vm for the exact existing QEMU/VMware classes. Synchronize active focus
  on config.reloaded. Delete the watcher and its Home Manager link, and remove
  its now-obsolete startup command. Preserve the other four startup commands,
  shell quoting, token suppression, ampersands, and sleep exactly.
- Use native float then pin dispatches for Shift+W. Share directional and numeric
  binding definitions without changing bindings or their flags.
- Replace pidof hyprlock guards with the compositor's `hyprctl -j locked` state;
  no DMS/logind self-session guessing, timeout changes, or actual locking tests.
- Remove disable_watchdog_warning: the current UWSM unit's ExecStart uses
  start-hyprland and the live child runs Hyprland --watchdog-fd.
- Move the eight old compositor .conf files to tests/hypr/fixtures/legacy, retaining
  independent regression references outside the deployed config directory.
  Keep hypridle.conf and untouched user-generated hypr/dms data.
- Assert device, gesture, monitor mode/position, callback, reload, and startup
  behavior. Accept installed Hyprland 0.57.x or newer for verification; reject
  deprecations rather than allowing the old todo warning.
- Refresh documentation for current unpinned 0.57.2 and explain (not implement)
  user service management of the remaining startup processes.

## Safety and limits

Work in an isolated worktree carrying the dirty baseline. Do not push, merge,
reload, lock, suspend, launch VMs, kill the existing watcher, or switch systems.
An already-running watcher survives a config reload: recommend a logout/login
after eventual deployment. Real graphical/lock acceptance remains user-driven.

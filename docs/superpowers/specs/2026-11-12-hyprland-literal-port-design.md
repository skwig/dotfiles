# Hyprland literal Lua port

Approved direction: user requested a 1:1 migration now, with improvements deferred.

## Intent and constraints

Preserve the original Hyprlang files' boundaries, order, variables/aliases,
commands, rule names, explicit/unspecified fields, and comments. Change only
language/API syntax and necessary compatibility plumbing. Keep the three removed
focus scripts deleted. Preserve unrelated user work. No live activation.

## Approaches

- Patch the refactored Lua layout: fewer edits but retains unnecessary structural
  changes and makes comparison harder.
- **Selected: literal port** using the original basenames with `.lua` extensions,
  separate globals/monitor host links, explicit declarations, and original order.

## Interfaces and decisions

- `hyprland.globals.<host>.lua` returns `{mainMonitor=...}`.
- `hyprland.monitors.<host>.lua` returns a function taking that globals table;
  it defines the original aliases and scale once, registers monitors, and returns
  `{leftMonitor, centerMonitor, rightMonitor, scale}` for the entrypoint.
- `hyprland.keybindings.lua` and `hyprland.apps.lua` register declarations when
  required. `hyprland.keybindings.mainMod.lua` returns a function taking `mainMod`,
  called twice as the old source fragment was. Preserve repeated shared todo
  declarations if the real API supports replacement under the same name.
- Retain `on_created_empty` and `todo-workspace`; document the expected 0.57.0
  deprecation instead of redesigning lifecycle behavior.
- Use the start event as the Lua replacement for exec-once; strip initial
  workspace tracking from the entire spawned shell command's environment so
  startup processes retain the old executor behavior.
- Preserve Shift+W's shell/IPC sequence, changing only dispatcher syntax.
- Isolate compatibility settings for changed upstream defaults; do not claim
  that config translation can revert all compositor implementation changes.
- Tests compare executed Lua registrations to the old fragments, exercise edits
  to shared monitor/scale values, and reload with cached modules cleared as the
  compositor does. No obsolete script expectations.

Non-goals: new abstractions, reorganized comments/settings, cleanup of old `.conf`
files before rollout, new session management, or modernization of deprecated APIs.

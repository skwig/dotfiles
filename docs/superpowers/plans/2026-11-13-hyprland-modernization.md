# Hyprland Modernization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans task-by-task.

**Goal:** Apply the approved post-migration improvements except startup management.
**Architecture:** Native Lua callbacks/shared bindings; compositor lock-state
guards; historical fixtures outside deployed config; no service redesign.
**Tech Stack:** Hyprland 0.57+, Lua, Bash, Python stdlib, NixOS/Home Manager.
**Spec:** `docs/superpowers/specs/2026-11-13-hyprland-modernization-design.md`

## Global Constraints

- No startup service conversion; retain all four non-watcher commands exactly.
- Preserve user work, both modifier sets, monitor variables, and current behavior.
- No pushing, merging, switching systems, live reloads, or disruptive tests.
- No package pins, input updates, or changes to private VM scripts.

## Review Focus

- Todo creation must launch only an empty special:todo, with an explicit target.
- VM focus callbacks must handle nil/ordinary/VM and resynchronize after reload.
- Native Shift+W must dispatch float then pin; existing binding sets stay intact.
- Lock guards must test actual compositor state, never process existence.
- Startup must not restart on reload; obsolete watcher must not remain deployed.

## Task 1: Native events and shared bindings

**Files:** `hypr/hyprland{,.apps,.keybindings.mainMod,.events}.lua`,
`bin/vm-submap-on-vm-focus.sh`, `nixos/modules/system.nix`, tests capture/parity/IPC.
**Interface:** events.lua subscribes once to workspace.created, window.active,
and config.reloaded; uses hl.get_active_window() for reload synchronization.

- [ ] Add failing callback, single-registration, Shift+W, full binding-equivalence,
  reload, and four-command startup tests. Compare against retained legacy inputs.
- [ ] Implement native todo/VM callbacks and binding loops; remove the obsolete
  watcher startup, script, and Home Manager link only.
- [ ] Run the migration suite through green and commit only intended files.

## Task 2: Lock-state guards and obsolete session workaround

**Files:** `hypr/hypridle.conf`, `hypr/hyprland.lua`, `tests/hypr/ipc.sh`, parity tests.
**Interface:** locked JSON is `{locked: boolean}`; guard DPMS only when true.

- [ ] Add failing tests for locked/unlocked/invalid/missing state and unchanged
  DPMS ordering/timeouts; expect watchdog override absent.
- [ ] Replace hyprlock process guards with locked-state queries and remove only
  the confirmed obsolete watchdog-warning setting.
- [ ] Run all tests and commit.

## Task 3: Fixtures, coverage, verification, docs

**Files:** eight compositor `.conf` files move to `tests/hypr/fixtures/legacy/`;
`tests/hypr/{parity.py,verify.sh,run.sh}`, `docs/hyprland-migration.md`.
**Interface:** independent old-config references now live below test fixtures;
the verifier accepts >=0.57 and requires config ok with no deprecations reported.

- [ ] Add monitor/device/gesture baseline and reload assertions, verifier version
  cases, and ensure no deprecated effects are emitted by executed config.
- [ ] Move obsolete active-directory files into test fixtures; preserve all user
  files and hypridle.conf. Update commands/version checks and docs.
- [ ] Run tests, real verifier for both hosts, and both NixOS builds without
  switching; request an independent review and resolve blocking findings.
- [ ] Explain service lifecycle/readiness/logging tradeoffs for the unchanged
  startup commands in final handoff; no startup redesign implementation.

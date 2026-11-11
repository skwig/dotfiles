# Hyprland Literal Port Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct the first migration into a literal Lua translation.
**Architecture:** Original basenames and file boundaries, explicit declarations,
and passed tables/functions only where Lua requires scope between files.
**Tech Stack:** Lua, Bash, Python stdlib, NixOS/Home Manager, Hyprland 0.57.0.
**Spec:** `docs/superpowers/specs/2026-11-12-hyprland-literal-port-design.md`

## Global Constraints

- 1:1 stage only; improvements deferred.
- Preserve unrelated working-tree changes and the three intentional script deletions.
- Keep live links, system generation, and old `.conf` files unchanged.
- Keep existing 0.57.0 package pin; accept only the known todo deprecation.

## Review Focus

- Editing shared globals/scale must change monitors, environment, and workspaces together.
- Both modifier sets, all flags, all shell commands, and declaration order must match.
- Cached modules must register again after reload, without startup process duplication.
- Todo lifecycle must remain on_created_empty, not a new event-based behavior.
- Compatibility helpers must not introduce shell interpolation or token leakage.

## Task 1: Executable parity checks

**Files:** `tests/hypr/{capture.lua,parity.py,ipc.sh,run.sh}`.
**Interface:** capture.lua accepts host and fixture-root arguments and emits JSON
registrations; parity.py executes it under controlled host edits and reloads.

- [ ] Write comparison tests against original settings, animations, curves,
  bindings/actions/flags, windows/layers, and file evaluation order. Add alias,
  shared-scale, startup-environment, cached-reload, and todo-rule assertions.
- [ ] Run tests and record expected failures against the refactored port.
- [ ] Remove only expectations for the three deleted focus scripts.

## Task 2: Literal port and deployment wiring

**Files:** `hypr/hyprland.lua`, new `hypr/hyprland.{globals,monitors}.<host>.lua`,
new `hypr/hyprland.keybindings{,.mainMod}.lua`, new `hypr/hyprland.apps.lua`,
both host `configuration.nix` files; remove only superseded first-port Lua files.
**Interface:** globals and monitors tables/functions follow the approved spec;
entrypoint requires ordinary fragments and calls mainMod fragment twice.

- [ ] Restore separate host fragments and shared variables.
- [ ] Translate original files explicitly in original order, including comments,
  inactive examples, todo names/mechanism, and unspecified persistent fields.
- [ ] Preserve startup token suppression per spawned process and Shift+W shell IPC.
- [ ] Wire the two original-style `.lua` Home Manager links for each host.
- [ ] Run parity tests through green, syntax checks, and surviving IPC tests.

## Task 3: Real verification and handoff

**Files:** `tests/hypr/verify.sh`, `docs/hyprland-migration.md`.
**Interface:** verifier fixture deploys both host fragments and accepts precisely
the known on_created_empty warning, without suppressing other diagnostics.

- [ ] Update real verifier fixture and docs to describe the corrected layout,
  expected deprecation, compatibility limits, and intentional script deletions.
- [ ] Run the whole migration suite and actual 0.57.0 verifier for both hosts.
- [ ] Evaluate/build both host symlink derivations and NixOS toplevels without switching.
- [ ] Request independent read-only review focused on the original `.conf` parity.
- [ ] Record findings, fix blocking defects test-first, and leave activation gated.

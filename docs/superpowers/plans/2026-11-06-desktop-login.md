# On-demand desktop login implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide `sudo desktop-login` over SSH to start the configured user's local Hyprland session without enabling boot-time autologin, and open a GitHub PR.

**Architecture:** Keep the existing greetd settings as the normal configuration. A fixed launcher consumes a root-only request under `/run/desktop-login` and selects a separately generated one-shot configuration only while the request is fresh. Its initial session uses UWSM; no passwords, persistent systemd overrides, sudo policy changes, or Sunshine changes are needed.

**Tech Stack:** NixOS modules, Bash, greetd, systemd/logind, Python standard-library tests.

**Spec:** The approved implementation sketch and security discussion in this conversation: root-only requests, 15-second expiry, existing graphical-session refusal, unchanged tuigreet on normal startup and logout.

## Global constraints

- Preserve unrelated edits in the original checkout.
- Use the configured `username`, greetd package and unstable UWSM package.
- Do not rebuild/switch the running machine or restart its display manager while testing.
- No boot-time autologin and no passwordless sudo rule.
- Requests live under `/run/desktop-login`, owned by root with directory mode `0700`, and expire after 15 seconds.
- Document the local-login race and physical-console exposure.

## Review focus

- Expired, malformed and implausibly future-dated requests must be consumed without granting login.
- A second launcher execution must use the normal configuration even after the first granted login.
- Existing X11/Wayland sessions, failed session enumeration and failed session inspection must prevent restarting greetd.
- Failed restarts must remove pending authorization; interrupted requests must expire.
- Concurrent requests must not race; root-only state must contain no credentials.

## File structure

- `nixos/modules/remote-desktop-login.nix`: packages, generated TOML, runtime directory and fixed launcher.
- `nixos/modules/remote-desktop-login/{launcher,desktop-login}.sh`: request consumption and privileged login helper.
- `nixos/modules/hyprland.nix`: module import.
- `nixos/tests/test_desktop_login.py`: isolated subprocess tests with temporary state and mocked system commands.
- `nixos/README.md`: usage, recovery, security caveats and test command.

### Task 1: Implement and test the one-shot helper

**Interfaces:** Scripts receive fixed paths through Nix-generated wrappers; tests supply temporary paths and mock executables. The installed interface is `desktop-login` with no username/configuration arguments.

- [x] Write tests for normal startup; valid, expired, malformed and overlong-future requests; repeat consumption; non-root invocation; existing desktops; logind failures; concurrency; restart cleanup; and request permissions.
- [x] Run `python3 -m unittest discover -s nixos/tests -p 'test_desktop_login.py' -v` and observe missing-implementation failures.
- [x] Implement the scripts with consume-before-exec, a separate runfile, atomic request publication and nonblocking locking.
- [x] Implement and import the module, asserting normal `initial_session` is absent and preserving merged greetd settings.
- [x] Run tests and document usage and limitations.

### Task 2: Verify and publish

**Interfaces:** Uses Task 1's module/tests; produces a feature commit and PR against `master`.

- [x] Format Nix and syntax-check scripts.
- [x] Evaluate affected hosts and build helper/launcher derivations without changing the lock file; verify generated TOML. Blackbox/smallbox pass; vmbox has a pre-existing undefined `pkgs-unstable` reference at configuration.nix:48.
- [x] Re-run tests, inspect the diff and obtain whole-branch review; accurately report unavailable checks. All 17 tests pass; the review finding has a RED→GREEN regression. Live login/streaming testing is deferred to deployment.
- [x] Commit only feature files, push a feature branch and open a PR with verification and security limitations: https://github.com/skwig/dotfiles/pull/3.

## Execution status

- [x] Inspect repository and working-tree status.
- [x] Draft and self-review plan.
- [x] Obtain plan approval and isolated-worktree consent.
- [x] Task 1: implementation and tests.
- [x] Task 2: verification and PR.

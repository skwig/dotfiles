{ pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs-unstable; [
    opencode
    codex
    claude-code
  ];
}

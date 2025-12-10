{ pkgs-cuttingedge, ... }:

{
  environment.systemPackages = with pkgs-cuttingedge; [
    opencode
    codex
    claude-code
  ];
}

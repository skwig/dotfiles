{ pkgs-cuttingedge, ... }:

{
  environment.systemPackages = with pkgs-cuttingedge; [
    opencode
    codex
    claude-code
  ];

  # mkdir -p ~/.config/opencode/superpowers
  # git clone https://github.com/obra/superpowers.git ~/.config/opencode/superpowers
}

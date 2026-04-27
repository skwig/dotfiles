{
  pkgs,
  pkgs-cuttingedge,
  username,
  dotfiles,
  ...
}:

{
  environment.systemPackages = with pkgs-cuttingedge; [
    opencode
    # codex
    # claude-code
  ];

  home-manager.users.${username} =
    { config, ... }:
    let
    in
    {
      home.file.".config/opencode/opencode.json".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/opencode/opencode.json;
      home.file.".config/opencode/command/superpowers:brainstorming.md".source =
        config.lib.file.mkOutOfStoreSymlink "/${dotfiles}/opencode/command/superpowers:brainstorming.md";
      home.file.".config/opencode/command/superpowers:executing-plans.md".source =
        config.lib.file.mkOutOfStoreSymlink "/${dotfiles}/opencode/command/superpowers:executing-plans.md";
      home.file.".config/opencode/command/superpowers:writing-plans.md".source =
        config.lib.file.mkOutOfStoreSymlink "/${dotfiles}/opencode/command/superpowers:writing-plans.md";
    };
}

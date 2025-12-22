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
    codex
    claude-code
  ];

  home-manager.users.${username} =
    { config, ... }:
    let
      superpowers = pkgs.fetchFromGitHub {
        owner = "obra";
        repo = "superpowers";
        tag = "v4.0.0";
        sha256 = "sha256-Wkty3kSuQmiscw0/Xx+mev7/pQqSb+DzaTqRZ0cAreE=";
      };
    in
    {
      home.file.".config/opencode/opencode.json".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/opencode/opencode.json;
      home.file.".config/opencode/command".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/opencode/command;
      home.file.".config/opencode/skills".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/opencode/skills;

      home.file.".config/opencode/plugin/superpowers.js".source =
        "${superpowers}/.opencode/plugin/superpowers.js";
    };
}

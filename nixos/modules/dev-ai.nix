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
      home-config = /home/${username}/.config;
    in
    {
      home.file.".config/opencode/opencode.json".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/opencode/opencode.json;
      home.file.".config/opencode/command".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/opencode/command;
      home.file.".config/opencode/skills".source =
        config.lib.file.mkOutOfStoreSymlink /${dotfiles}/opencode/skills;

      # Superpowers cannot be declaratively added to opencore or declaratively cloned & symlinked by nix (core dump)
      home.activation.superpowers = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        SUPERPOWERS_DIR="$HOME/.config/opencode/superpowers"
        SUPERPOWERS_REPO="https://github.com/obra/superpowers.git"
        SUPERPOWERS_TAG="v4.0.0"

        if [ ! -d "$SUPERPOWERS_DIR" ]; then
          echo "Installing superpowers $SUPERPOWERS_TAG..."
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone --depth 1 --branch "$SUPERPOWERS_TAG" "$SUPERPOWERS_REPO" "$SUPERPOWERS_DIR"
        else
          echo "Updating superpowers to $SUPERPOWERS_TAG..."
          cd "$SUPERPOWERS_DIR"
          CURRENT_TAG=$($DRY_RUN_CMD ${pkgs.git}/bin/git describe --tags --exact-match 2>/dev/null || echo "unknown")
          if [ "$CURRENT_TAG" != "$SUPERPOWERS_TAG" ]; then
            $DRY_RUN_CMD ${pkgs.git}/bin/git fetch --depth 1 origin "refs/tags/$SUPERPOWERS_TAG:refs/tags/$SUPERPOWERS_TAG"
            $DRY_RUN_CMD ${pkgs.git}/bin/git checkout "$SUPERPOWERS_TAG"
          else
            echo "Already at $SUPERPOWERS_TAG"
          fi
        fi
      '';

      home.file.".config/opencode/plugin/superpowers.js".source =
        config.lib.file.mkOutOfStoreSymlink /${home-config}/opencode/superpowers/.opencode/plugin/superpowers.js;
    };
}

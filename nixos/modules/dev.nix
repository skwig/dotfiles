{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim
    tree-sitter

    nixd
    nixfmt

    prettierd
    fixjson
    tofu-ls
    bash-language-server

    lua51Packages.lua
    lua51Packages.luarocks
    lua-language-server
    stylua

    git
    git-lfs
    gh
    lazygit

    lazydocker

    gcc
    gnumake
    cmake

    just

    go

    fzf
    ripgrep
    fd

    cargo

    nodejs_24

    jq
    yq

    k6
    nushell
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  virtualisation.docker = {
    enable = true;
  };

  # for neovim LSPs etc
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [ ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };
}

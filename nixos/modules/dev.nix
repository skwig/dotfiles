{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim

    lua51Packages.lua
    lua51Packages.luarocks

    git
    gh
    lazygit

    lazydocker

    gcc
    gnumake
    cmake

    fzf
    ripgrep
    fd

    cargo

    nodejs_24

    jq
    yq

    nix-search-cli
    nixd
    nixfmt-rfc-style
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  virtualisation.docker = {
    enable = true;
  };
}

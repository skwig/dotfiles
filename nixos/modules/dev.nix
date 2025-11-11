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

    go

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

    nushell
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
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

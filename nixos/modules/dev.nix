{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    neovim

    git
    gh
    lazygit

    lazydocker

    gcc
    gnumake
    cmake

    fzf
    ripgrep

    cargo

    nodejs_24

    jq
    yq

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

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

    nodejs_23

    jq
    yq
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  virtualisation.docker = { enable = true; };
}

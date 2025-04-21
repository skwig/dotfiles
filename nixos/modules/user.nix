{ pkgs, ... }:

{
  users.users.skwig = {
    isNormalUser = true;
    description = "skwig";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "docker" ];
  };

  programs.zsh.enable = true;
}

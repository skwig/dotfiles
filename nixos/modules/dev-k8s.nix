{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    kubelogin
    pkgs-unstable.freelens-bin
  ];
}

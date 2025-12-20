{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    yamllint
    k9s
    kubelogin
    pkgs-unstable.freelens-bin
  ];
}

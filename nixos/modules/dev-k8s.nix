{ pkgs, pkgs-pr, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    kubelogin
    pkgs-pr.freelens-bin
  ];
}

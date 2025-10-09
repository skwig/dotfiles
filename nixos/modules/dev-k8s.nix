{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    kubectl
    k9s
    kubelogin
  ];
}

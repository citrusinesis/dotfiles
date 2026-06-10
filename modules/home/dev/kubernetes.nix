{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    kubectx

    kubernetes-helm
    helmfile

    kustomize
    k9s
    stern

    fluxcd
  ];
}

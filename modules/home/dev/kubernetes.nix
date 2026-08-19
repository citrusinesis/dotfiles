{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    kubectx

    kubernetes-helm
    helmfile

    kustomize
    stern

    fluxcd
  ];

  programs.k9s.enable = true;
}

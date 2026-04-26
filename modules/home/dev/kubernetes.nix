{ lib, pkgs, ... }:

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

  programs.zsh.initContent = lib.mkOrder 560 ''
    if command -v kubectl &> /dev/null; then
      source <(kubectl completion zsh)
    fi

    if command -v helm &> /dev/null; then
      source <(helm completion zsh)
    fi

    if command -v flux &> /dev/null; then
      source <(flux completion zsh)
    fi
  '';
}

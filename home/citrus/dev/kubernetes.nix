{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    minikube
    kubectl
  ];

  programs.zsh = {
    shellAliases = {
      kubectl = "minikube kubectl --";
    };

    initContent = lib.mkOrder 560 ''
      # Kubernetes tools completion
      if command -v minikube &> /dev/null; then
        source <(minikube completion zsh)
      fi

      if command -v helm &> /dev/null; then
        source <(helm completion zsh)
      fi

      if command -v minikube &> /dev/null && [ "$(minikube status -o json 2>/dev/null | ${pkgs.jq}/bin/jq -r '.Host // "Stopped"')" = "Running" ]; then
        source <(minikube kubectl -- completion zsh)
        if [ "$(minikube config get driver 2>/dev/null)" = "docker" ]; then
          eval $(minikube -p minikube docker-env)
        fi
      fi
    '';
  };
}

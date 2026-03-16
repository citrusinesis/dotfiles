{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
  ];

  programs.zsh.initContent = lib.mkOrder 560 ''
    if command -v kubectl &> /dev/null; then
      source <(kubectl completion zsh)
    fi

    if command -v helm &> /dev/null; then
      source <(helm completion zsh)
    fi
  '';
}

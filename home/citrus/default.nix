{ config, lib, pkgs, inputs, username, ... }:

{
  imports = [
    ./programs
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
  );

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    tmux
    zellij

    nil
    nixd
    nixfmt-rfc-style

    ripgrep
    fd
    jq
    tree

    btop
    bat
    eza
    fzf
    fastfetch

    gh

    minikube
    kubectl
    podman
    containerd

    file
    du-dust
    duf
    procs
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    slack
    obsidian
    pkgs.unstable.claude-code
    pkgs.unstable.firefox
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    coreutils
    claude-code
  ];
}

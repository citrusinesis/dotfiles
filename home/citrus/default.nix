{ lib, pkgs, username, ... }:

{
  imports = [
    ./programs
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
  );

  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.isDarwin false;
  targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.isDarwin true;

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
    lorri
    entr

    python3
    nodejs
    bun
    go
    rustc
    cargo

    minikube
    kubectl
    podman

    file
    dust
    duf
    procs

    pkgs.unstable.claude-code
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    containerd
    slack
    obsidian
    pkgs.unstable.firefox
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    coreutils
  ];
}
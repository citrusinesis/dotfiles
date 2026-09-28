{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    nixd
    nixfmt
    nix-output-monitor
    nix-tree
    nix-diff
    statix
    deadnix
    nvd
  ];

  programs.nh = {
    enable = true;
    flake = "${config.xdg.configHome}/dotfiles";
  };
}

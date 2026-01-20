{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    nix-output-monitor
    nix-tree
    nix-diff
    statix
    deadnix
  ];
}

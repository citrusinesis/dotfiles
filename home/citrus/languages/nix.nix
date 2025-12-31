{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style
    nix-tree
    nix-diff
    statix
    deadnix
  ];
}

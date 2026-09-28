{ pkgs, ... }:

{
  home.packages = with pkgs; [
    teleport
  ];
}

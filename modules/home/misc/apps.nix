{ lib, pkgs, ... }:

{
  home.packages = lib.optionals pkgs.stdenv.isDarwin (
    with pkgs;
    [
      element-desktop
      ghostty-bin
      monitorcontrol
      obsidian
    ]
  );
}

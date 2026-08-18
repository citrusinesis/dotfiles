{ lib, pkgs, ... }:

{
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin (
    with pkgs;
    [
      element-desktop
      ghostty-bin
      monitorcontrol
      obsidian
    ]
  );
}

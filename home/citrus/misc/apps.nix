{ lib, pkgs, ... }:

{
  home.packages = lib.optionals pkgs.stdenv.isLinux (
    with pkgs;
    [
      slack
      obsidian
      pkgs.unstable.firefox
    ]
  );
}

{
  lib,
  pkgs,
  flake,
  ...
}:

let
  inherit (flake.inputs) self;
  personal = import (self + /personal.nix);
  username = personal.user.username;
in
{
  imports = [ self.homeModules.default ];

  home.username = username;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
  );
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.isDarwin true;
  targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.isDarwin false;
}

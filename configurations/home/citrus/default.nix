{
  lib,
  pkgs,
  flake,
  ...
}:

let
  inherit (flake.inputs) self;
  username = (import (self + /personal.nix)).user.username;
in
{
  imports = [
    ./cli
    ./shell
    ./editors
    ./terminals
    ./dev
    ./languages
    ./misc
  ];

  home.username = username;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
  );

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.isDarwin false;
  targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.isDarwin true;
}

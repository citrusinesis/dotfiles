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

  localFiles = [
    ./local/ssh-local.nix
    ./local/teleport-local.nix
  ];
in
{
  imports = [
    (self + /modules/home/cli)
    (self + /modules/home/dev)
    (self + /modules/home/editors)
    (self + /modules/home/languages)
    (self + /modules/home/misc)
    (self + /modules/home/shell)
    (self + /modules/home/terminals)
  ]
  ++ builtins.filter builtins.pathExists localFiles;

  home.username = username;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}"
  );

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.isDarwin false;
  targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.isDarwin true;
}

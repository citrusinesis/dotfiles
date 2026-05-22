{
  lib,
  pkgs,
  flake,
  username,
  ...
}:

let
  inherit (flake.inputs) self;
  userName = username;
in
{
  imports = [ self.homeModules.development ];

  dotfiles.home.gui.enable = true;

  home.username = userName;
  home.homeDirectory = lib.mkDefault (
    if pkgs.stdenv.isDarwin then "/Users/${userName}" else "/home/${userName}"
  );
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.isDarwin true;
  targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.isDarwin false;
}

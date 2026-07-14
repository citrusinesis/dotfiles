{
  config,
  flake,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.home;
  personal = import (flake.inputs.self + /personal.nix);
in
{
  options.dotfiles.home = {
    gui.enable = lib.mkEnableOption "graphical Home Manager integrations";
    username = lib.mkOption {
      type = lib.types.str;
      default = personal.user.username;
      description = "Account managed by this Home Manager configuration.";
    };
  };

  config = {
    home.username = cfg.username;
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;
    targets.darwin.linkApps.enable = lib.mkIf pkgs.stdenv.isDarwin true;
    targets.darwin.copyApps.enable = lib.mkIf pkgs.stdenv.isDarwin false;
  };
}

{
  flake,
  pkgs,
  lib,
  ...
}:

let
  inherit (flake.inputs) self;
  personal = import (self + /personal.nix);
in

{
  system = {
    primaryUser = personal.user.username;
    stateVersion = 5;
  };

  time.timeZone = lib.mkDefault "UTC";

  programs.zsh.enable = true;
  programs.bash.enable = true;

  environment.systemPackages = with pkgs; [
    coreutils
    container
  ];
}

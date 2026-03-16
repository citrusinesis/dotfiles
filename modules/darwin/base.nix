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

  environment.systemPackages = with pkgs; [
    coreutils
    container
  ];
}

{
  config,
  flake,
  lib,
  pkgs,
  ...
}:

let
  personal = import (flake.inputs.self + /personal.nix);
in
{
  options.dotfiles.primaryUser = lib.mkOption {
    type = lib.types.str;
    default = personal.user.username;
    description = "Unprivileged account allowed to manage this Nix installation.";
  };

  config.nix = {
    optimise.automatic = true;
    package = pkgs.lixPackageSets.latest.lix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      builders-use-substitutes = true;
      max-jobs = "auto";
      cores = 0;

      trusted-users = lib.mkForce [
        "root"
        config.dotfiles.primaryUser
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  config.nixpkgs = {
    overlays = [ flake.inputs.self.overlays.default ];

    config = {
      allowUnfree = true;
    };
  };
}

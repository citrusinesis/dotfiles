{ flake, pkgs, ... }:

let
  personal = import (flake.inputs.self + /personal.nix);
in
{
  nix = {
    optimise.automatic = true;
    package =
      if pkgs.stdenv.isDarwin then pkgs.lixPackageSets.latest.lix else pkgs.lixPackageSets.stable.lix;

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      builders-use-substitutes = true;
      max-jobs = "auto";
      cores = 0;

      trusted-users = [
        "root"
        (if pkgs.stdenv.isDarwin then personal.user.username else "@wheel")
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnsupportedSystem = true;
      allowUnfree = true;
    };
  };
}

{ flake, pkgs, ... }:

let
  personal = import (flake.inputs.self + /personal.nix);
in
{
  nix = {
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
    overlays = [ flake.inputs.self.overlays.default ];

    config = {
      allowUnfree = true;
    };
  };
}

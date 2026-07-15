{
  config,
  flake,
  lib,
  pkgs,
  ...
}:

let
  personal = import (flake.inputs.self + /personal.nix);
  lix = pkgs.lixPackageSets.latest.lix;
in
{
  options.dotfiles.primaryUser = lib.mkOption {
    type = lib.types.str;
    default = personal.user.username;
    description = "Unprivileged account allowed to manage this Nix installation.";
  };

  config.nix = {
    optimise.automatic = true;
    package =
      if pkgs.stdenv.isDarwin then
        # Lix's install-check environment pulls in pyxattr, whose Python 3.14
        # wheel build currently crashes in libffi under the macOS sandbox.
        lix.overrideAttrs (old: {
          doInstallCheck = false;
          mesonFlags = map (lib.replaceStrings
            [ "-Denable-tests=true" ]
            [ "-Denable-tests=false" ]
          ) old.mesonFlags;
        })
      else
        lix;

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

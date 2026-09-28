{
  config,
  lib,
  pkgs,
  ...
}:

let
  lix = pkgs.lixPackageSets.latest.lix;
in
{
  config.nix = {
    optimise.automatic = true;
    channel.enable = false;
    package = lix;

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

}

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
  homeManagerBackup = pkgs.writeShellApplication {
    name = "home-manager-backup";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      if [ "$#" -ne 1 ]; then
        echo "usage: home-manager-backup PATH" >&2
        exit 64
      fi

      target="$1"
      timestamp="$(date +%Y%m%d-%H%M%S)"
      backup="$target.home-manager-$timestamp.bak"
      suffix=0

      while [ -e "$backup" ] || [ -L "$backup" ]; do
        suffix=$((suffix + 1))
        backup="$target.home-manager-$timestamp.$suffix.bak"
      done

      mv -- "$target" "$backup"
      printf 'Backed up %s to %s\n' "$target" "$backup"
    '';
  };
in
{
  options.dotfiles.primaryUser = lib.mkOption {
    type = lib.types.str;
    default = personal.user.username;
    description = "Unprivileged account allowed to manage this Nix installation.";
  };

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

  config.nixpkgs = {
    overlays = [ flake.inputs.self.overlays.default ];

    config = {
      allowUnfree = true;
    };
  };

  # Home Manager invokes this only for files that would otherwise block an
  # activation. Keep every collision with a timestamp instead of reusing one
  # fixed .bak path.
  config.home-manager.backupCommand = lib.getExe homeManagerBackup;
}

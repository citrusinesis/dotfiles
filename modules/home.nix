{
  config,
  dotfilesUnmanaged,
  lib,
  pkgs,
  ...
}:
{
  home = {
    # Each activation form must prefer its own packages over an older Home profile.
    sessionPath = lib.mkBefore [ "${config.home.profileDirectory}/bin" ];
    activation.configureBackup = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      # Keep explicit nh/Home Manager backup options; supply our shared default.
      if [[ -z "''${HOME_MANAGER_BACKUP_COMMAND:-}" && -z "''${HOME_MANAGER_BACKUP_EXT:-}" ]]; then
        export HOME_MANAGER_BACKUP_COMMAND=${
          lib.escapeShellArg (lib.getExe (import ../lib/home-manager-backup.nix { inherit pkgs; }))
        }
      fi
    '';
  };
  nix.package = lib.mkDefault pkgs.lixPackageSets.latest.lix;
  targets.genericLinux.enable = lib.mkDefault (dotfilesUnmanaged && pkgs.stdenv.hostPlatform.isLinux);
}

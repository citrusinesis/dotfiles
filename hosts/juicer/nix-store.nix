{ lib, pkgs, ... }:
let
  # The encrypted APFS volume created by the installer on juicer.
  volumeUUID = "46786343-EDAE-40B0-BA7F-6103D102708B";
  launcherPath = "/Library/Scripts/nix-darwin/nix-store-mount";
  launcher = pkgs.writeText "nix-store-mount" ''
    #!/bin/sh
    set -eu
    set -o pipefail

    # Activating an already mounted system must not try to unlock it again.
    if /sbin/mount | /usr/bin/grep -q ' on /nix ('; then
      exit 0
    fi

    /usr/bin/security find-generic-password -s "Nix Store" -w |
      /usr/sbin/diskutil apfs unlockVolume ${volumeUUID} -mountpoint /nix -stdinpassphrase
  '';
in
{
  # Install a real file; a store symlink would make unlocking depend on itself.
  system.activationScripts.launchd.text = lib.mkBefore ''
    /usr/bin/install -d -o root -g wheel -m 0755 /Library/Scripts/nix-darwin
    /usr/bin/install -o root -g wheel -m 0555 ${launcher} ${launcherPath}
  '';

  launchd.daemons.darwin-store.serviceConfig = {
    ProgramArguments = [ launcherPath ];
    RunAtLoad = true;
    KeepAlive.SuccessfulExit = false;
    ThrottleInterval = 10;
    StandardOutPath = "/var/log/nix-store-mount.log";
    StandardErrorPath = "/var/log/nix-store-mount.log";
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
let
  launcherDirectory = "/Library/Scripts/nix-darwin";
  services = {
    activate-system = "nix-system-activation";
  }
  // lib.optionalAttrs config.nix.enable {
    nix-daemon = "nix-daemon";
  }
  // lib.optionalAttrs (config.nix.enable && config.nix.gc.automatic) {
    nix-gc = "nix-gc";
  }
  // lib.optionalAttrs (config.nix.enable && config.nix.optimise.automatic) {
    nix-optimise = "nix-store-optimise";
  };
  launcher = pkgs.writeText "nix-launchd-launcher" ''
    #!/bin/sh
    exec /bin/sh "$@"
  '';
in
{
  # Stable executable paths keep Login Items identifiable across generations.
  # These must be real files outside /nix: they also run before the store mounts.
  system.activationScripts.launchd.text = lib.mkBefore ''
    /usr/bin/install -d -o root -g wheel -m 0755 ${launcherDirectory}
    ${lib.concatMapStringsSep "\n" (name: ''
      /usr/bin/install -o root -g wheel -m 0555 ${launcher} ${launcherDirectory}/${name}
    '') (builtins.attrValues services)}
  '';

  launchd.daemons = lib.mapAttrs (service: name: {
    serviceConfig.ProgramArguments = lib.mkForce [
      "${launcherDirectory}/${name}"
      "-c"
      "/bin/wait4path /nix/store && exec ${config.launchd.daemons.${service}.command}"
    ];
  }) services;
}

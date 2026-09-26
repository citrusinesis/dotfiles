{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.containerization;
  upstreamPackage = inputs.nix-apple-container.packages.${pkgs.stdenv.hostPlatform.system}.default;
  defaults = (pkgs.formats.toml { }).generate "container-config.toml" {
    container = {
      cpus = 8;
      memory = "4g";
    };
    dns.domain = "test";
  };
  kernelLink = "${
    config.users.users.${cfg.user}.home
  }/Library/Application Support/com.apple.container/kernels/default.kernel-arm64";
in
{
  imports = [
    # Login Items uses the executable basename. Give this module's scripts a
    # bin/<name> path so Nix store hashes do not become their display names.
    (import inputs.nix-apple-container.darwinModules.default {
      inherit config lib;
      pkgs = pkgs // {
        writeShellScript =
          name: text:
          let
            scriptName = if name == "bootstrap-managed-containers" then "apple-container-runtime" else name;
          in
          lib.getExe (pkgs.writeShellScriptBin scriptName text);
      };
    })
  ];

  # Declare host workloads through services.containerization.containers.
  services.containerization.enable = lib.mkDefault true;

  # Container 1.3 reads TOML instead of macOS defaults. Ship immutable defaults
  # with the upstream package; leave its signed binaries and version untouched.
  services.containerization.package = lib.mkDefault (
    upstreamPackage.overrideAttrs (old: {
      installPhase = old.installPhase + ''
        mkdir -p "$out/etc/container"
        cp ${defaults} "$out/etc/container/config.toml"
      '';
    })
  );

  # Upstream starts an absent runtime but leaves a running old version alone.
  # Stop it before upstream's setup when the package or kernel has changed.
  system.activationScripts.preActivation.text = lib.mkIf cfg.enable (
    lib.mkOrder 600 ''
      if container_status=$(/usr/bin/sudo -H -u ${lib.escapeShellArg cfg.user} -- ${lib.getExe cfg.package} system status --format json 2>/dev/null); then
        container_install_root=$(printf '%s' "$container_status" | ${lib.getExe pkgs.jq} -r '.paths.installRoot // .installRoot // ""')
        container_kernel=$(/usr/bin/readlink ${lib.escapeShellArg kernelLink} 2>/dev/null || true)
        if [ "''${container_install_root%/}" != ${lib.escapeShellArg (toString cfg.package)} ] || [ "$container_kernel" != ${lib.escapeShellArg (toString cfg.kernel)} ]; then
          echo "Restarting Apple Container for the updated package or kernel..."
          /usr/bin/sudo -H -u ${lib.escapeShellArg cfg.user} -- ${lib.getExe cfg.package} system stop || exit 1
        fi
      fi
    ''
  );

  # Upstream writes this Background-only agent but does not load it during a
  # switch. Refresh it in the existing user's domain without requiring login.
  system.activationScripts.postActivation.text = lib.mkIf cfg.enable (
    lib.mkOrder 1600 ''
      container_uid=$(/usr/bin/id -u ${lib.escapeShellArg cfg.user})
      container_domain="user/$container_uid"
      if /bin/launchctl print "$container_domain" >/dev/null 2>&1; then
        if /bin/launchctl print "$container_domain/nix-apple-container.runtime" >/dev/null 2>&1; then
          /bin/launchctl bootout "$container_domain/nix-apple-container.runtime" || exit 1
        fi
        /bin/launchctl enable "$container_domain/nix-apple-container.runtime" || exit 1
        /bin/launchctl bootstrap "$container_domain" /Library/LaunchAgents/nix-apple-container.runtime.plist || exit 1
      fi
    ''
  );
}

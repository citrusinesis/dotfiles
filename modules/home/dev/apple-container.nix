{
  config,
  lib,
  pkgs,
  osConfig ? { },
  ...
}:

let
  runtimeManagedByDarwin = osConfig ? containerRuntime;
  runtime = osConfig.containerRuntime or null;
  enabled = pkgs.stdenv.isDarwin && runtime == "container";
  configSource = ./apple-container.toml;
  configPath = "${config.xdg.configHome}/container/config.toml";
  logDir = "${config.xdg.stateHome}/container";
  appliedConfigHash = "${logDir}/applied-config.sha256";
  legacyConfigPath = "${config.home.homeDirectory}/Library/Application Support/com.apple.container/config/config.toml";
  legacyLaunchAgent = "${config.home.homeDirectory}/Library/LaunchAgents/org.nixos.container-system-start.plist";

  containerSystemStart = pkgs.writeShellScript "container-system-start" ''
    set -eu
    umask 077
    ${pkgs.coreutils}/bin/install -d -m 0700 ${lib.escapeShellArg logDir}
    /usr/bin/touch ${lib.escapeShellArg "${logDir}/system-start.log"}
    /bin/chmod 0600 ${lib.escapeShellArg "${logDir}/system-start.log"}
    exec >>${lib.escapeShellArg "${logDir}/system-start.log"} 2>&1

    config_hash=$(
      {
        ${pkgs.coreutils}/bin/sha256sum ${lib.escapeShellArg configPath}
        /usr/bin/printf '%s\n' ${lib.escapeShellArg (toString pkgs.dotfilesPackages.apple-container)}
      } | ${pkgs.coreutils}/bin/sha256sum | ${pkgs.gawk}/bin/awk '{ print $1 }'
    )
    if ${pkgs.dotfilesPackages.apple-container}/bin/container system status >/dev/null 2>&1 \
      && [ -f ${lib.escapeShellArg appliedConfigHash} ] \
      && /usr/bin/grep -Fqx "$config_hash" ${lib.escapeShellArg appliedConfigHash}; then
      exit 0
    fi

    echo "==> $(/bin/date -u +%FT%TZ) applying apple/container configuration"
    if ${pkgs.dotfilesPackages.apple-container}/bin/container system status >/dev/null 2>&1; then
      ${pkgs.dotfilesPackages.apple-container}/bin/container system stop
    fi
    ${pkgs.dotfilesPackages.apple-container}/bin/container system start --enable-kernel-install

    hash_tmp=${lib.escapeShellArg appliedConfigHash}.tmp.$$
    /usr/bin/printf '%s\n' "$config_hash" > "$hash_tmp"
    /bin/mv -f "$hash_tmp" ${lib.escapeShellArg appliedConfigHash}
  '';
in
{
  config = lib.mkMerge [
    (lib.mkIf (pkgs.stdenv.isDarwin && runtimeManagedByDarwin) {
      # One-time migration from the pre-Home-Manager launchd job. Only remove
      # Nix-managed symlinks; user-owned files at these paths are preserved.
      home.activation.migrateAppleContainer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        old_label="org.nixos.container-system-start"
        if /bin/launchctl print "gui/$UID/$old_label" >/dev/null 2>&1; then
          /bin/launchctl bootout "gui/$UID/$old_label" >/dev/null 2>&1 || true
        fi

        if [[ -e ${lib.escapeShellArg legacyLaunchAgent} || -L ${lib.escapeShellArg legacyLaunchAgent} ]]; then
          old_label=$(/usr/bin/plutil -extract Label raw -o - ${lib.escapeShellArg legacyLaunchAgent} 2>/dev/null || true)
          old_program=$(/usr/bin/plutil -extract ProgramArguments.0 raw -o - ${lib.escapeShellArg legacyLaunchAgent} 2>/dev/null || true)
          if [[ "$old_label" == "org.nixos.container-system-start" \
            && "$old_program" == /nix/store/*container-system-start* ]]; then
            run /bin/rm -f ${lib.escapeShellArg legacyLaunchAgent}
          fi
        fi
      '';
    })

    (lib.mkIf enabled {
      # Apple chmods a copy of this file, so it cannot be a Nix store symlink.
      home.activation.writeAppleContainerConfig = lib.hm.dag.entryAfter [ "migrateAppleContainer" ] ''
        if [[ -L ${lib.escapeShellArg legacyConfigPath} ]]; then
          legacy_target=$(/usr/bin/readlink ${lib.escapeShellArg legacyConfigPath})
          if [[ "$legacy_target" == /nix/store/*-home-manager-files/.config/container/config.toml ]]; then
            run /bin/rm -f ${lib.escapeShellArg legacyConfigPath}
          fi
        fi

        if [[ -L ${lib.escapeShellArg configPath} ]] \
          || ! ${pkgs.coreutils}/bin/cmp --silent ${configSource} ${lib.escapeShellArg configPath}; then
          run /bin/mkdir -p ${lib.escapeShellArg (dirOf configPath)}
          run /bin/rm -f ${lib.escapeShellArg configPath}
          run /usr/bin/install -m 0644 ${configSource} ${lib.escapeShellArg configPath}
        fi
      '';

      launchd.agents.container-system-start = {
        enable = true;
        config = {
          ProgramArguments = [ "${containerSystemStart}" ];
          RunAtLoad = true;

          # config.toml is read only at service startup.
          WatchPaths = [ configPath ];

          # Retry only failed starts.
          KeepAlive.SuccessfulExit = false;
          ThrottleInterval = 30;
          ProcessType = "Background";
        };
      };
    })

    # Deregister Apple-managed jobs when switching runtimes.
    (lib.mkIf (pkgs.stdenv.isDarwin && runtimeManagedByDarwin && !enabled) {
      home.activation.stopAppleContainer = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
        if ${pkgs.dotfilesPackages.apple-container}/bin/container system status >/dev/null 2>&1; then
          echo "Stopping apple/container services"
          run ${pkgs.dotfilesPackages.apple-container}/bin/container system stop
        fi
      '';
    })
  ];
}

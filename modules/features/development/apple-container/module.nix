{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.dotfiles.home.appleContainer;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  enabled = isDarwin && cfg.enable;
  configSource = ./apple-container.toml;
  configPath = "${config.xdg.configHome}/container/config.toml";
  logDir = "${config.xdg.stateHome}/container";
  appliedConfigHash = "${logDir}/applied-config.sha256";
  managedConfigHash = "${logDir}/managed-config.sha256";
  managedConfigHashValue = builtins.hashFile "sha256" configSource;
  legacyConfigPath = "${config.home.homeDirectory}/Library/Application Support/com.apple.container/config/config.toml";
  legacyLaunchAgent = "${config.home.homeDirectory}/Library/LaunchAgents/org.nixos.container-system-start.plist";

  installManagedConfig = pkgs.writeShellScript "install-apple-container-config" ''
    set -eu
    umask 077

    ${pkgs.coreutils}/bin/install -d -m 0700 ${lib.escapeShellArg (dirOf configPath)}
    ${pkgs.coreutils}/bin/rm -f ${lib.escapeShellArg configPath}
    ${pkgs.coreutils}/bin/install -m 0644 ${configSource} ${lib.escapeShellArg configPath}

    ${pkgs.coreutils}/bin/install -d -m 0700 ${lib.escapeShellArg logDir}
    hash_tmp=${lib.escapeShellArg managedConfigHash}.tmp.$$
    /usr/bin/printf '%s\n' ${lib.escapeShellArg managedConfigHashValue} > "$hash_tmp"
    /bin/chmod 0600 "$hash_tmp"
    /bin/mv -f "$hash_tmp" ${lib.escapeShellArg managedConfigHash}
  '';

  cleanupManagedFiles = pkgs.writeShellScript "cleanup-apple-container-files" ''
    set -eu

    remove_config=false
    if [ -L ${lib.escapeShellArg configPath} ]; then
      target=$(/usr/bin/readlink ${lib.escapeShellArg configPath})
      case "$target" in
        /nix/store/*-home-manager-files/*) remove_config=true ;;
      esac
    elif [ -f ${lib.escapeShellArg configPath} ]; then
      current_hash=$(${pkgs.coreutils}/bin/sha256sum ${lib.escapeShellArg configPath} | ${pkgs.gawk}/bin/awk '{ print $1 }')
      if [ -f ${lib.escapeShellArg managedConfigHash} ] \
        && /usr/bin/grep -Fqx "$current_hash" ${lib.escapeShellArg managedConfigHash}; then
        remove_config=true
      elif ${pkgs.diffutils}/bin/cmp --silent ${configSource} ${lib.escapeShellArg configPath}; then
        # Compatibility with generations created before the ownership marker.
        remove_config=true
      fi
    fi

    if [ "$remove_config" = true ]; then
      ${pkgs.coreutils}/bin/rm -f ${lib.escapeShellArg configPath}
    fi

    if [ -L ${lib.escapeShellArg legacyConfigPath} ]; then
      legacy_target=$(/usr/bin/readlink ${lib.escapeShellArg legacyConfigPath})
      case "$legacy_target" in
        /nix/store/*-home-manager-files/*)
          ${pkgs.coreutils}/bin/rm -f ${lib.escapeShellArg legacyConfigPath}
          ;;
      esac
    fi

    ${pkgs.coreutils}/bin/rm -f \
      ${lib.escapeShellArg managedConfigHash} \
      ${lib.escapeShellArg appliedConfigHash} \
      ${lib.escapeShellArg "${logDir}/system-start.log"}
    /bin/rmdir ${lib.escapeShellArg logDir} 2>/dev/null || true
    /bin/rmdir ${lib.escapeShellArg (dirOf configPath)} 2>/dev/null || true
  '';

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
  options.dotfiles.home.appleContainer.enable = lib.mkEnableOption "apple/container";

  config = lib.mkMerge [
    (lib.mkIf isDarwin {
      # One-time migration from the pre-Home-Manager launchd job. Only remove
      # Nix-managed symlinks; user-owned files at these paths are preserved.
      home.activation.migrateAppleContainer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [[ -e ${lib.escapeShellArg legacyLaunchAgent} || -L ${lib.escapeShellArg legacyLaunchAgent} ]]; then
          old_label=$(/usr/bin/plutil -extract Label raw -o - ${lib.escapeShellArg legacyLaunchAgent} 2>/dev/null || true)
          old_program=$(/usr/bin/plutil -extract ProgramArguments.0 raw -o - ${lib.escapeShellArg legacyLaunchAgent} 2>/dev/null || true)
          if [[ "$old_label" == "org.nixos.container-system-start" \
            && "$old_program" == /nix/store/*container-system-start* ]]; then
            if /bin/launchctl print "gui/$UID/$old_label" >/dev/null 2>&1; then
              /bin/launchctl bootout "gui/$UID/$old_label" >/dev/null 2>&1 || true
            fi
            run /bin/rm -f ${lib.escapeShellArg legacyLaunchAgent}
          fi
        fi
      '';
    })

    (lib.mkIf enabled {
      home.packages = [ pkgs.dotfilesPackages.apple-container ];

      # Apple chmods a copy of this file, so it cannot be a Nix store symlink.
      home.activation.writeAppleContainerConfig = lib.hm.dag.entryAfter [ "migrateAppleContainer" ] ''
        if [[ -L ${lib.escapeShellArg legacyConfigPath} ]]; then
          legacy_target=$(/usr/bin/readlink ${lib.escapeShellArg legacyConfigPath})
          if [[ "$legacy_target" == /nix/store/*-home-manager-files/.config/container/config.toml ]]; then
            run /bin/rm -f ${lib.escapeShellArg legacyConfigPath}
          fi
        fi

        if [[ -L ${lib.escapeShellArg configPath} ]] \
          || ! ${pkgs.diffutils}/bin/cmp --silent ${configSource} ${lib.escapeShellArg configPath} \
          || ! /usr/bin/grep -Fqx ${lib.escapeShellArg managedConfigHashValue} ${lib.escapeShellArg managedConfigHash} 2>/dev/null; then
          run ${installManagedConfig}
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

    # Deregister only state previously owned by this module when opting out.
    (lib.mkIf (isDarwin && !enabled) {
      home.activation.stopAppleContainer = lib.hm.dag.entryAfter [ "setupLaunchAgents" ] ''
        owns_managed_state=false
        if [[ -f ${lib.escapeShellArg managedConfigHash} \
          || -f ${lib.escapeShellArg appliedConfigHash} ]]; then
          owns_managed_state=true
        elif [[ -L ${lib.escapeShellArg configPath} ]]; then
          config_target=$(/usr/bin/readlink ${lib.escapeShellArg configPath})
          if [[ "$config_target" == /nix/store/*-home-manager-files/* ]]; then
            owns_managed_state=true
          fi
        fi

        if [[ "$owns_managed_state" == true ]]; then
          if ${pkgs.dotfilesPackages.apple-container}/bin/container system status >/dev/null 2>&1; then
            echo "Stopping apple/container services"
            run ${pkgs.dotfilesPackages.apple-container}/bin/container system stop
          fi
          run ${cleanupManagedFiles}
        fi
      '';
    })
  ];
}

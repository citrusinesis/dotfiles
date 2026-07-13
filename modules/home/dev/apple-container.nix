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

  containerSystemStart = pkgs.writeShellScript "container-system-start" ''
    /bin/mkdir -p ${lib.escapeShellArg logDir}
    exec >>${lib.escapeShellArg "${logDir}/system-start.log"} 2>&1

    echo "==> $(/bin/date -u +%FT%TZ) restarting apple/container services"
    ${pkgs.container}/bin/container system stop || true
    exec ${pkgs.container}/bin/container system start --enable-kernel-install
  '';
in
{
  config = lib.mkMerge [
    (lib.mkIf enabled {
      # Apple chmods a copy of this file, so it cannot be a Nix store symlink.
      home.activation.writeAppleContainerConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
        if ${pkgs.container}/bin/container system status >/dev/null 2>&1; then
          echo "Stopping apple/container services"
          run ${pkgs.container}/bin/container system stop
        fi
      '';
    })
  ];
}

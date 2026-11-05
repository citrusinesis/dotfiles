{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  package = pkgs.llm-agents.paseo;
  server = lib.getExe' package "paseo-server";

  servicePath = lib.concatStringsSep ":" (
    lib.optionals isLinux [ "/run/wrappers/bin" ]
    ++ [
      "${config.home.profileDirectory}/bin"
      "/run/current-system/sw/bin"
      "/nix/var/nix/profiles/default/bin"
    ]
    ++ lib.optionals isDarwin [
      "/opt/homebrew/bin"
      "/usr/local/bin"
      "/usr/bin"
      "/bin"
      "/usr/sbin"
      "/sbin"
    ]
  );

  environment = {
    PATH = servicePath;
    PASEO_RELAY_ENABLED = "true";
  };
in
{
  home.packages = [ package ];

  dotfiles.casks = [ "paseo" ];

  launchd.agents.paseo = lib.mkIf isDarwin {
    enable = true;
    config = {
      Label = "com.local.Paseo";
      ProgramArguments = [ server ];
      EnvironmentVariables = environment;
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
    };
  };

  systemd.user.services.paseo = lib.mkIf isLinux {
    Unit.Description = "Paseo daemon for coding agents";
    Service = {
      ExecStart = server;
      Environment = lib.mapAttrsToList (name: value: "${name}=${value}") environment;
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 15;
    };
    Install.WantedBy = [ "default.target" ];
  };
}

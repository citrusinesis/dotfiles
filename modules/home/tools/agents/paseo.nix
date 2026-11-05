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

  # Skills pick a profile by its notes through list_profiles; /implement picks by id.
  agentProfiles = [
    {
      id = "orchestrator";
      name = "Orchestrator";
      provider = "claude";
      model = "claude-opus-5-5";
      modeId = "auto";
      thinkingOptionId = "medium";
      notes = "Plans and orchestrates work: specs, /implement runs and reviews. Delegates implementation to the Implementer profiles.";
    }
    {
      id = "implementer";
      name = "Implementer";
      provider = "codex";
      model = "gpt-6.1-sol";
      modeId = "auto-review";
      thinkingOptionId = "high";
      notes = "Default implementation agent for /implement tasks.";
    }
    {
      id = "implementer-claude";
      name = "Implementer (Claude)";
      provider = "claude";
      model = "claude-opus-5-5";
      modeId = "auto";
      thinkingOptionId = "medium";
      notes = "Implements /implement tasks when run with --agent claude or when Codex is unavailable. Also takes exploration and repetitive mechanical work.";
    }
    {
      id = "advisor";
      name = "Advisor";
      provider = "codex";
      model = "gpt-6-astra";
      modeId = "auto-review";
      thinkingOptionId = "high";
      notes = "Independent review and second opinions: paseo-advisor and committee reviews.";
    }
    {
      id = "advisor-claude";
      name = "Advisor (Claude)";
      provider = "claude";
      model = "claude-opus-5-5";
      modeId = "auto";
      thinkingOptionId = "medium";
      notes = "Second committee member alongside Advisor.";
    }
  ];
in
{
  home.packages = [ package ];

  dotfiles.casks = [ "paseo" ];

  launchd.agents.paseo = lib.mkIf isDarwin {
    enable = true;
    config = {
      Label = "com.local.Paseo";
      ProgramArguments = [ server ];
      EnvironmentVariables = {
        PATH = servicePath;
        PASEO_RELAY_ENABLED = "true";
      };
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = false;
    };
  };

  systemd.user.services.paseo = lib.mkIf isLinux {
    Unit.Description = "Paseo daemon for coding agents";
    Service = {
      ExecStart = server;
      Environment = [
        "PATH=${servicePath}"
        "PASEO_RELAY_ENABLED=true"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 15;
    };
    Install.WantedBy = [ "default.target" ];
  };

  home.activation.paseoAgentProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${lib.getExe package} daemon config set daemon.agentProfiles ${lib.escapeShellArg (builtins.toJSON agentProfiles)} --home ${config.home.homeDirectory}/.paseo
  '';
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pf;
  anyRulesEnabled = cfg."screen-sharing".enable || cfg.ssh.enable;
  rules = import ./rules.nix { inherit cfg lib; };

  managedStateFile = "/var/db/pf-tailscale.anchor";
  enableTokenFile = "/var/run/pf-tailscale.enable-token";
  activationLockFile = "/var/run/pf-tailscale.lock";

  writeScript =
    name:
    pkgs.writeTextFile {
      inherit name;
      executable = true;
      text = builtins.readFile ./scripts/${name}.sh;
    };
  loadBootRules = writeScript "load-boot-rules";
  updateRules = writeScript "update-rules";
  prepareState = writeScript "prepare-state";
  cleanupRules = writeScript "cleanup-rules";

  passRulesFile = pkgs.writeText "pf-tailscale-pass-rules" rules.passRules;
  blockRulesFile = pkgs.writeText "pf-tailscale-block-rules" rules.blockRules;
  defaultPfConfFile = pkgs.writeText "pf.conf" rules.applePfConf;

  loadBootArguments = [
    "${loadBootRules}"
    enableTokenFile
    activationLockFile
  ];

  updateArguments = [
    "${updateRules}"
    rules.runtimeAnchorName
    cfg.tailscaleIPv4
    cfg.tailscaleIPv6
    "${passRulesFile}"
    "${blockRulesFile}"
    activationLockFile
  ];

  cleanupArguments = [
    "${cleanupRules}"
    managedStateFile
    enableTokenFile
    activationLockFile
    "${defaultPfConfFile}"
  ];
in
{
  options.pf = {
    anchorName = lib.mkOption {
      type = lib.types.strMatching "^[A-Za-z0-9_.-]+$";
      default = "com.local.tailscale-only";
      description = "PF anchor name used for Tailscale-only access rules.";
    };

    tailscaleIPv4 = lib.mkOption {
      type = lib.types.strMatching "^[0-9.]+/[0-9]+$";
      default = "100.64.0.0/10";
      description = "Tailscale IPv4 CGNAT range allowed by PF rules.";
    };

    tailscaleIPv6 = lib.mkOption {
      type = lib.types.strMatching "^[0-9A-Fa-f:]+/[0-9]+$";
      default = "fd7a:115c:a1e0::/48";
      description = "Tailscale IPv6 ULA range allowed by PF rules.";
    };

    screen-sharing = {
      enable = lib.mkEnableOption "restrict Screen Sharing to the Tailscale interface";

      high-performance = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow High Performance Screen Sharing UDP ports 5900-5902 from Tailscale only.";
      };
    };

    ssh = {
      enable = lib.mkEnableOption "restrict SSH to the Tailscale interface";

      port = lib.mkOption {
        type = lib.types.port;
        default = 22;
        description = "SSH TCP port restricted by the PF rules.";
      };
    };
  };

  config = lib.mkMerge [
    {
      # Keep cleanup active even when every PF option is disabled. The state file
      # records whether a previous generation installed rules that must be removed.
      system.activationScripts.postActivation.text =
        if anyRulesEnabled then
          ''
            ${lib.escapeShellArgs [
              "${prepareState}"
              managedStateFile
              cfg.anchorName
            ]}
            ${lib.escapeShellArgs loadBootArguments}

            if ${lib.escapeShellArgs updateArguments}; then
              update_status=0
            else
              update_status=$?
            fi

            if [ "$update_status" -ne 0 ] && [ "$update_status" -ne 75 ]; then
              exit "$update_status"
            fi

            # Remove rules left by versions that used a top-level anchor.
            /sbin/pfctl -a ${lib.escapeShellArg cfg.anchorName} -F rules
          ''
        else
          ''
            ${lib.escapeShellArgs cleanupArguments}
          '';
    }

    (lib.mkIf anyRulesEnabled {
      environment.etc."pf.conf".text = rules.pfConf;
      environment.etc."pf.anchors/${cfg.anchorName}".text = rules.denyOnlyRules;
      environment.etc."newsyslog.d/pf-tailscale.conf".text = ''
        # logfilename                 owner:group  mode  count  size  when  flags
        /var/log/pf-tailscale.log     root:wheel   640   5      1024  *     NJ
      '';

      # macOS loads /etc/pf.conf at startup but intentionally does not enable PF.
      # This job installs deny-only rules without depending on Tailscale. The PF
      # reference token it owns is persisted so disabling the options can release it.
      launchd.daemons.pf-tailscale-bootstrap.serviceConfig = {
        ProgramArguments = loadBootArguments;
        RunAtLoad = true;
        KeepAlive.SuccessfulExit = false;
        ThrottleInterval = 10;
        ProcessType = "Background";
        StandardOutPath = "/var/log/pf-tailscale.log";
        StandardErrorPath = "/var/log/pf-tailscale.log";
      };

      launchd.daemons.pf-tailscale.serviceConfig = {
        ProgramArguments = updateArguments;
        RunAtLoad = true;
        StartInterval = 60;
        KeepAlive.SuccessfulExit = false;
        ThrottleInterval = 30;
        ProcessType = "Background";
        StandardOutPath = "/var/log/pf-tailscale.log";
        StandardErrorPath = "/var/log/pf-tailscale.log";
      };
    })
  ];
}

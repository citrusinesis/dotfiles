{
  config,
  lib,
  ...
}:

let
  cfg = config.pf;

  anyRulesEnabled = cfg."screen-sharing".enable || cfg.ssh.enable;

  pfConfText = ''
    #
    # Default PF configuration file.
    #
    # This file contains the main ruleset, which gets automatically loaded
    # at startup. PF will not be automatically enabled, however. Instead,
    # each component which utilizes PF is responsible for enabling and disabling
    # PF via -E and -X as documented in pfctl(8). That will ensure that PF
    # is disabled only when the last enable reference is released.
    #
    # Care must be taken to ensure that the main ruleset does not get flushed,
    # as the nested anchors rely on the anchor point defined here. In addition,
    # to the anchors loaded by this file, some system services would dynamically
    # insert anchors into the main ruleset. These anchors will be added only when
    # the system service is used and would removed on termination of the service.
    #
    # See pf.conf(5) for syntax.
    #

    #
    # com.apple anchor point
    #
    scrub-anchor "com.apple/*"
    nat-anchor "com.apple/*"
    rdr-anchor "com.apple/*"
    dummynet-anchor "com.apple/*"
    anchor "com.apple/*"
    load anchor "com.apple" from "/etc/pf.anchors/com.apple"

    anchor "${cfg.anchorName}"
    load anchor "${cfg.anchorName}" from "/etc/pf.anchors/${cfg.anchorName}"
  '';

  anchorRules = lib.concatStringsSep "\n\n" (
    [
      ''
        tailscale_v4 = "${cfg.tailscaleIPv4}"
        tailscale_v6 = "${cfg.tailscaleIPv6}"
      ''
    ]
    ++ lib.optional cfg."screen-sharing".enable ''
      # Standard Screen Sharing
      pass in quick inet proto tcp from $tailscale_v4 to any port 5900 keep state
      pass in quick inet6 proto tcp from $tailscale_v6 to any port 5900 keep state
      block drop in quick proto tcp from any to any port 5900
    ''
    ++ lib.optional (cfg."screen-sharing".enable && cfg."screen-sharing".high-performance) ''
      # High Performance Screen Sharing
      pass in quick inet proto udp from $tailscale_v4 to any port 5900:5902 keep state
      pass in quick inet6 proto udp from $tailscale_v6 to any port 5900:5902 keep state
      block drop in quick proto udp from any to any port 5900:5902
    ''
    ++ lib.optional cfg.ssh.enable ''
      # SSH
      pass in quick inet proto tcp from $tailscale_v4 to any port ${toString cfg.ssh.port} keep state
      pass in quick inet6 proto tcp from $tailscale_v6 to any port ${toString cfg.ssh.port} keep state
      block drop in quick proto tcp from any to any port ${toString cfg.ssh.port}
    ''
  );
in
{
  options.pf = {
    anchorName = lib.mkOption {
      type = lib.types.str;
      default = "com.local.tailscale-only";
      description = "PF anchor name used for Tailscale-only access rules.";
    };

    tailscaleIPv4 = lib.mkOption {
      type = lib.types.str;
      default = "100.64.0.0/10";
      description = "Tailscale IPv4 CGNAT range allowed by PF rules.";
    };

    tailscaleIPv6 = lib.mkOption {
      type = lib.types.str;
      default = "fd7a:115c:a1e0::/48";
      description = "Tailscale IPv6 ULA range allowed by PF rules.";
    };

    screen-sharing = {
      enable = lib.mkEnableOption "restrict Screen Sharing to Tailscale IP ranges";

      high-performance = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Allow High Performance Screen Sharing UDP ports 5900-5902 from Tailscale only.";
      };
    };

    ssh = {
      enable = lib.mkEnableOption "restrict SSH to Tailscale IP ranges";

      port = lib.mkOption {
        type = lib.types.port;
        default = 22;
        description = "SSH TCP port restricted by the PF rules.";
      };
    };
  };

  config = lib.mkIf anyRulesEnabled {
    environment.etc."pf.anchors/${cfg.anchorName}".text = anchorRules;
    environment.etc."pf.conf.local".text = pfConfText;

    launchd.daemons.pf-tailscale = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/sbin/pfctl -f /etc/pf.conf.local && /sbin/pfctl -e 2>/dev/null; exit 0"
        ];
        RunAtLoad = true;
      };
    };
  };
}

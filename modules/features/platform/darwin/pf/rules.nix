{ cfg, lib }:

let
  runtimeAnchorName = "com.apple/${cfg.anchorName}";

  passRules = lib.concatStringsSep "\n" (
    lib.optional cfg."screen-sharing".enable ''
      # Standard Screen Sharing: require the Tailscale interface and source range.
      pass in quick on $tailscale_if inet proto tcp from $tailscale_v4 to any port 5900 keep state
      pass in quick on $tailscale_if inet6 proto tcp from $tailscale_v6 to any port 5900 keep state
    ''
    ++ lib.optional (cfg."screen-sharing".enable && cfg."screen-sharing".high-performance) ''
      # High Performance Screen Sharing.
      pass in quick on $tailscale_if inet proto udp from $tailscale_v4 to any port 5900:5902 keep state
      pass in quick on $tailscale_if inet6 proto udp from $tailscale_v6 to any port 5900:5902 keep state
    ''
    ++ lib.optional cfg.ssh.enable ''
      # SSH.
      pass in quick on $tailscale_if inet proto tcp from $tailscale_v4 to any port ${toString cfg.ssh.port} keep state
      pass in quick on $tailscale_if inet6 proto tcp from $tailscale_v6 to any port ${toString cfg.ssh.port} keep state
    ''
  );

  blockRules = lib.concatStringsSep "\n" (
    lib.optional cfg."screen-sharing".enable ''
      block drop in quick proto tcp from any to any port 5900
    ''
    ++ lib.optional (cfg."screen-sharing".enable && cfg."screen-sharing".high-performance) ''
      block drop in quick proto udp from any to any port 5900:5902
    ''
    ++ lib.optional cfg.ssh.enable ''
      block drop in quick proto tcp from any to any port ${toString cfg.ssh.port}
    ''
  );

  applePfConf = ''
    # Default macOS PF anchors.
    scrub-anchor "com.apple/*"
    nat-anchor "com.apple/*"
    rdr-anchor "com.apple/*"
    dummynet-anchor "com.apple/*"
    anchor "com.apple/*"
    load anchor "com.apple" from "/etc/pf.anchors/com.apple"
  '';
in
{
  inherit
    applePfConf
    blockRules
    passRules
    runtimeAnchorName
    ;

  denyOnlyRules = ''
    tailscale_if = "lo0"
    tailscale_v4 = "${cfg.tailscaleIPv4}"
    tailscale_v6 = "${cfg.tailscaleIPv6}"

    # Safe boot-time default. The launchd job replaces this anchor only after
    # it discovers an interface with a real Tailscale address.
    ${blockRules}
  '';

  # Keep Apple's standard wildcard anchors and load the deny-only rules into the
  # same nested anchor that the runtime updater replaces once Tailscale is ready.
  pfConf = ''
    ${applePfConf}

    # Fail closed at boot, before the Tailscale interface is available.
    load anchor "${runtimeAnchorName}" from "/etc/pf.anchors/${cfg.anchorName}"
  '';
}

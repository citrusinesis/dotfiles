{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.pf;
  anyRulesEnabled = cfg."screen-sharing".enable || cfg.ssh.enable;
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

  denyOnlyRules = ''
    tailscale_if = "lo0"
    tailscale_v4 = "${cfg.tailscaleIPv4}"
    tailscale_v6 = "${cfg.tailscaleIPv6}"

    # Safe boot-time default. The launchd job replaces this anchor only after
    # it discovers an interface with a real Tailscale address.
    ${blockRules}
  '';

  updateRules = pkgs.writeShellScript "update-tailscale-pf-rules" ''
    set -eu
    umask 077

    load_anchor() {
      if ! pfctl_output=$(
        /sbin/pfctl \
          -a ${lib.escapeShellArg runtimeAnchorName} \
          -R \
          -o none \
          -f "$1" 2>&1
      ); then
        /usr/bin/printf '%s\n' "$pfctl_output" >&2
        return 1
      fi

      # Apple's pfctl emits this main-ruleset warning even for an isolated
      # anchor transaction. Keep every other successful diagnostic visible.
      /usr/bin/printf '%s\n' "$pfctl_output" | /usr/bin/awk '
        $0 == "pfctl: Use of -f option, could result in flushing of rules" { next }
        $0 == "present in the main ruleset added by the system at startup." { next }
        $0 == "See /etc/pf.conf for further details." { next }
        NF { print > "/dev/stderr" }
      '
    }

    temporary_dir=$(/usr/bin/mktemp -d /var/run/tailscale-pf.XXXXXX)
    anchor_candidate="$temporary_dir/anchor"
    trap '/bin/rm -rf "$temporary_dir"' EXIT HUP INT TERM

    tailscale_if=$(
      /sbin/ifconfig -a | /usr/bin/awk '
        /^[^[:space:]]+:/ {
          interface = $1
          sub(/:$/, "", interface)
        }
        $1 == "inet" {
          split($2, octets, ".")
          if (interface ~ /^utun[0-9]+$/ && octets[1] == 100 && octets[2] >= 64 && octets[2] <= 127) {
            print interface
            exit
          }
        }
        $1 == "inet6" && interface ~ /^utun[0-9]+$/ && tolower($2) ~ /^fd7a:115c:a1e0:/ {
          print interface
          exit
        }
      '
    )

    if ! /usr/bin/printf '%s\n' "$tailscale_if" | /usr/bin/grep -Eq '^[A-Za-z0-9_.-]+$'; then
      tailscale_if=lo0
      tailscale_ready=false
    else
      tailscale_ready=true
    fi

    {
      /usr/bin/printf 'tailscale_if = "%s"\n' "$tailscale_if"
      /usr/bin/printf 'tailscale_v4 = "%s"\n' ${lib.escapeShellArg cfg.tailscaleIPv4}
      /usr/bin/printf 'tailscale_v6 = "%s"\n\n' ${lib.escapeShellArg cfg.tailscaleIPv6}

      if "$tailscale_ready"; then
        /usr/bin/printf '%s\n' ${lib.escapeShellArg passRules}
      else
        /usr/bin/printf '%s\n' '# Tailscale is not ready; install deny-only rules and retry.'
      fi

      /usr/bin/printf '%s\n' ${lib.escapeShellArg blockRules}
    } > "$anchor_candidate"

    # The existing com.apple/* hook evaluates this direct child anchor. Loading
    # filter rules only avoids both the main ruleset and unsupported ALTQ.
    load_anchor "$anchor_candidate"

    if ! /sbin/pfctl -s info | /usr/bin/grep -q '^Status: Enabled'; then
      /sbin/pfctl -E
    fi

    if ! "$tailscale_ready"; then
      exit 75
    fi
  '';
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

  config = lib.mkIf anyRulesEnabled {
    environment.etc."pf.anchors/${cfg.anchorName}".text = denyOnlyRules;
    environment.etc."newsyslog.d/pf-tailscale.conf".text = ''
      # logfilename                 owner:group  mode  count  size  when  flags
      /var/log/pf-tailscale.log     root:wheel   640   5      1024  *     NJ
    '';

    # Load the new nested anchor before clearing rules from the legacy top-level
    # anchor. Exit 75 means deny-only rules were installed while Tailscale was
    # unavailable, so activation can safely continue and launchd will retry.
    system.activationScripts.postActivation.text = ''
      if ${updateRules}; then
        update_status=0
      else
        update_status=$?
      fi

      if [ "$update_status" -ne 0 ] && [ "$update_status" -ne 75 ]; then
        exit "$update_status"
      fi

      /sbin/pfctl -a ${lib.escapeShellArg cfg.anchorName} -F rules
    '';

    launchd.daemons.pf-tailscale.serviceConfig = {
      ProgramArguments = [ "${updateRules}" ];
      RunAtLoad = true;
      StartInterval = 60;
      KeepAlive.SuccessfulExit = false;
      ThrottleInterval = 30;
      ProcessType = "Background";
      StandardOutPath = "/var/log/pf-tailscale.log";
      StandardErrorPath = "/var/log/pf-tailscale.log";
    };
  };
}

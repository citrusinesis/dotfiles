{ pkgs, ... }:

{
  services.tailscale = {
    enable = true;
    extraSetFlags = [
      "--advertise-exit-node"
      "--ssh"
    ];
  };

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };

  systemd.services.tailscale-udp-optimization = {
    description = "Enable UDP forwarding optimizations for the Tailscale exit node";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "tailscale-udp-optimize" ''
        set -eu
        netdev="$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 | ${pkgs.gawk}/bin/awk '{ print $5; exit }')"
        if [ -n "$netdev" ]; then
          exec ${pkgs.ethtool}/bin/ethtool -K "$netdev" rx-udp-gro-forwarding on rx-gro-list off
        fi
      '';
    };
  };
}

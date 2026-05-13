{ lib, ... }:

{
  # Site-specific address/gateway/DNS values intentionally live outside the Nix
  # module in /etc/capitol/workspace-network.env. The host-local
  # capitol-static-network.service installed by Capitol applies them at runtime,
  # so shared user flakes do not need to commit private infrastructure facts.
  networking.hostName = lib.mkForce "ws-jh-song";
  networking.useDHCP = lib.mkForce false;
  networking.resolvconf.enable = lib.mkForce false;
  services.resolved.enable = lib.mkForce false;
  environment.etc."resolv.conf".enable = lib.mkForce false;

  # Keep the Capitol-provisioned workspace user passwordless without embedding
  # private network facts in this module. The init script adds jh-song to
  # wheel when passwordless_sudo is enabled.
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  boot.specialFileSystems."/sys/kernel/debug".enable = lib.mkForce false;
  boot.specialFileSystems."/sys/kernel/tracing".enable = lib.mkForce false;
  systemd.suppressedSystemUnits = [
    "sys-kernel-debug.mount"
    "sys-kernel-tracing.mount"
  ];

  systemd.services.capitol-static-network = {
    description = "Apply Capitol workspace static network";
    wantedBy = [ "multi-user.target" ];
    before = [
      "tailscaled.service"
      "network-online.target"
    ];
    after = [ "sys-subsystem-net-devices-eth0.device" ];
    wants = [ "sys-subsystem-net-devices-eth0.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/etc/capitol/apply-static-network.sh";
    };
  };

  systemd.services.tailscaled = {
    wants = [ "capitol-static-network.service" ];
    after = [ "capitol-static-network.service" ];
  };
}

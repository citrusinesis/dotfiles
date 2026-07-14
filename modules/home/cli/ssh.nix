{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        ServerAliveInterval = "60";
        ServerAliveCountMax = "30";
        TCPKeepAlive = "yes";
        Compression = "yes";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/control/%C";
        ControlPersist = "600";
        StrictHostKeyChecking = "ask";
        HashKnownHosts = "yes";
      };
    };

    includes = [ "~/.ssh/config.local" ];
  };

  home.activation.sshControlPermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.coreutils}/bin/install -d -m 0700 ${lib.escapeShellArg "${config.home.homeDirectory}/.ssh/control"}
  '';

  home.packages = with pkgs; [
    ssh-audit
    sshpass
  ];
}

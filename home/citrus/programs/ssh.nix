{ config, lib, pkgs, ... }:

{
  programs.ssh = {
    enable = true;

    extraConfig = ''
      Host *
        AddKeysToAgent yes
        IdentitiesOnly yes
        ServerAliveInterval 60
        ServerAliveCountMax 30
        TCPKeepAlive yes
        Compression yes
        ControlMaster auto
        ControlPath ~/.ssh/control/%r@%h:%p
        ControlPersist 600
        StrictHostKeyChecking ask
        VerifyHostKeyDNS yes
        HashKnownHosts yes
        UserKnownHostsFile ~/.ssh/known_hosts

      Include ~/.ssh/config.local
    '';
  };

  home.file.".ssh/.keep".text = "";
  home.activation.sshDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.ssh/control
    $DRY_RUN_CMD chmod 700 $VERBOSE_ARG ~/.ssh
    $DRY_RUN_CMD chmod 700 $VERBOSE_ARG ~/.ssh/control
  '';

  home.packages = with pkgs; [
    ssh-audit
    sshpass
    gnupg
    keychain
  ];
}

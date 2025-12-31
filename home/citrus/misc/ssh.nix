{ pkgs, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        extraOptions = {
          AddKeysToAgent = "yes";
          IdentitiesOnly = "yes";

          ServerAliveInterval = "60";
          ServerAliveCountMax = "30";
          TCPKeepAlive = "yes";

          Compression = "yes";

          ControlMaster = "auto";
          ControlPath = "~/.ssh/control/%r@%h:%p";
          ControlPersist = "600";

          StrictHostKeyChecking = "ask";
          VerifyHostKeyDNS = "yes";
          HashKnownHosts = "yes";
        };
      };
    };

    includes = [ "~/.ssh/config.local" ];
  };

  home.file.".ssh/control/.keep".text = "";

  home.packages = with pkgs; [
    ssh-audit
    sshpass
    gnupg
    keychain
  ];
}

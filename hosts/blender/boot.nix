{ ... }:

{
  boot.loader = {
    systemd-boot = {
      enable = true;
      # The editor lets anyone at the console boot with init=/bin/sh, which
      # bypasses login once the disk is unlocked by TPM rather than a passphrase.
      editor = false;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };
}

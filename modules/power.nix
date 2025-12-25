# Power management - disable sleep/suspend (NixOS)
{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  services.logind = {
    lidSwitch = "ignore";
    powerKey = "ignore";
    suspendKey = "ignore";
    hibernateKey = "ignore";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
    '';
  };
}

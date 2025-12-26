# PipeWire audio configuration (NixOS)
{ config, pkgs, lib, ... }:

lib.mkIf pkgs.stdenv.isLinux {
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Disable node suspension to fix audio delay
    wireplumber.configPackages = [
      (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/disable-suspension.conf" ''
        monitor.alsa.rules = [
          {
            matches = [
              { node.name = "~alsa_input.*" },
              { node.name = "~alsa_output.*" }
            ]
            actions = {
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
        monitor.bluez.rules = [
          {
            matches = [
              { node.name = "~bluez_input.*" },
              { node.name = "~bluez_output.*" }
            ]
            actions = {
              update-props = {
                session.suspend-timeout-seconds = 0
              }
            }
          }
        ]
      '')
    ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };
}

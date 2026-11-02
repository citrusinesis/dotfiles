{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.main = {
      layer = "top";
      position = "top";
      modules-left = [ "niri/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "pulseaudio"
        "network"
        "tray"
      ];

      clock.format = "{:%m/%d %a %H:%M}";
      pulseaudio = {
        format = "vol {volume}%";
        format-muted = "muted";
        on-click = "pwvucontrol";
      };
      network = {
        format-ethernet = "{ipaddr}";
        format-wifi = "{essid} {signalStrength}%";
        format-disconnected = "offline";
      };
    };
  };
}

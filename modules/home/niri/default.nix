{ pkgs, ... }:

{
  imports = [
    ../theme.nix
    ./waybar.nix
    ./idle.nix
  ];

  # Starts waybar, swayidle and the polkit agent with niri only, not under Plasma.
  wayland.systemd.target = "niri.service";

  # Validating at build time turns a config error into a failed switch instead of niri starting with its defaults.
  xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config.kdl" { nativeBuildInputs = [ pkgs.niri ]; }
      ''
        niri validate -c ${./config.kdl}
        cp ${./config.kdl} $out
      '';

  programs.fuzzel = {
    enable = true;
    settings.main = {
      terminal = "ghostty";
      font = "Hack Nerd Font:size=12";
    };
  };

  services.mako.enable = true;

  # Plasma's agent, already installed for the Plasma session; its own unit only starts with Plasma.
  systemd.user.services.polkit-kde-agent = {
    Unit = {
      Description = "KDE PolicyKit authentication agent";
      PartOf = [ "niri.service" ];
      After = [ "niri.service" ];
    };
    Service = {
      ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "niri.service" ];
  };

  home.packages = with pkgs; [
    wl-clipboard
    pwvucontrol
  ];
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  defaults = pkgs.runCommand "niri-default-config.kdl" { } ''
    cp ${pkgs.niri.doc}/share/doc/niri/default-config.kdl $out
    substituteInPlace $out \
      --replace-fail 'spawn-at-startup "waybar"' '// The shell is managed by its systemd user service.'
  '';
  niriConfig = pkgs.writeText "niri-config.kdl" ''
    include "${defaults}"
    include optional=true "${config.xdg.configHome}/niri/noctalia.kdl"

    ${lib.optionalString config.home.pointerCursor.enable ''
      cursor {
          xcursor-theme "${config.home.pointerCursor.name}"
          xcursor-size ${toString config.home.pointerCursor.size}
      }
    ''}

    input {
      ${config.dotfiles.niri.extraInputConfig}
    }

    layout {
        focus-ring { width 1; }
    }

    // Preserve the upstream keys while connecting the selected applications.
    binds {
        Mod+T hotkey-overlay-title="Open a Terminal: Ghostty" { spawn "ghostty"; }
        Mod+D hotkey-overlay-title="Run an Application: Noctalia" { spawn "noctalia" "msg" "panel-toggle" "launcher"; }
        Super+Alt+L hotkey-overlay-title="Lock the Screen: Noctalia" { spawn "noctalia" "msg" "session" "lock"; }
    }

    window-rule {
        // Keep focus/border colors at the edges of transparent windows.
        draw-border-with-background false
        geometry-corner-radius 12
        clip-to-geometry true
    }

    window-rule {
        match app-id="^com[.]mitchellh[.]ghostty$"
        background-effect { blur true; }
    }

    window-rule {
        match app-id="^dev.noctalia.Noctalia$"
        open-floating true
    }

    layer-rule {
        // Noctalia supplies the exact blur regions. The full-screen click
        // shield and wallpaper must not receive forced whole-surface blur.
        match namespace="^noctalia-(bar-.*|notification|dock|panel|attached-panel|osd)$"
        background-effect { xray false; }
    }

    ${config.dotfiles.niri.extraConfig}
  '';
in
{
  options.dotfiles.niri = {
    extraInputConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Host-specific input settings layered over niri defaults.";
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Host-specific niri settings layered over niri defaults.";
    };
  };

  config.xdg.configFile."niri/config.kdl".source =
    pkgs.runCommand "niri-config.kdl" { nativeBuildInputs = [ pkgs.niri ]; }
      ''
        niri validate -c ${niriConfig}
        cp ${niriConfig} $out
      '';
}

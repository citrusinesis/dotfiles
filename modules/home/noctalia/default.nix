{
  config,
  pkgs,
  ...
}:
let
  appearance = import ../../../lib/desktop-appearance.nix;
  wallpaper = pkgs.callPackage ../../../lib/desktop-wallpaper.nix { };
  qtSettings = version: {
    Appearance = {
      style = "Fusion";
      icon_theme = appearance.iconTheme;
      custom_palette = true;
      color_scheme_path = "${config.xdg.configHome}/qt${version}ct/colors/noctalia.conf";
      standard_dialogs = "xdgdesktopportal";
    };
    Fonts = {
      general = ''"${appearance.font},11,-1,5,50,0,0,0,0,0"'';
      fixed = ''"${appearance.monospaceFont},11,-1,5,50,0,0,0,0,0"'';
    };
  };
in
{
  wayland.systemd.target = "niri.service";

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = appearance.cursorName;
    size = appearance.cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      shell = {
        font_family = appearance.font;
        polkit_agent = true;
        launch_apps_as_systemd_services = true;
        panel.transparency_mode = "glass";
        shadow.alpha = 0.30;
        corner_radius_scale = 1.25;
        greeter_sync.auto_sync = true;
      };
      theme = {
        # Catppuccin's dark variant is Mocha, matching the flavor used by the catppuccin modules.
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
        # Ghostty takes Catppuccin Mocha directly from the shared ghostty module.
        templates.builtin_ids = [
          "gtk3"
          "gtk4"
          "qt"
        ];
        # Nix declares the include; only the generated palette stays mutable.
        templates.user.niri_palette = {
          input_path = "${pkgs.noctalia}/share/noctalia/assets/templates/niri/niri.kdl";
          output_path = "${config.xdg.configHome}/niri/noctalia.kdl";
        };
      };
      # Keep a local sunrise/sunset schedule available for night light without location lookup.
      location = {
        custom_schedule = true;
        sunrise = "07:00";
        sunset = "19:00";
      };
      bar.main = {
        radius = 16;
        border = "outline_variant";
        border_width = 1.0;
        background_opacity = 0.40;
        margin_ends = 16;
        margin_edge = 10;
        start = [
          "launcher"
          "workspaces"
        ];
        center = [ "clock" ];
        end = [
          "tray"
          "notifications"
          "network"
          "volume"
          "brightness"
          "control-center"
          "session"
        ];
      };
      wallpaper.default.path = "${wallpaper}";
      lockscreen.transition = [ "fade" ];
      notification.background_opacity = 0.70;
      osd.background_opacity = 0.70;
      brightness.enable_ddcutil = true;
    };
  };

  # Settings UI and IPC changes land in settings.toml, which overrides config.toml.
  # Dropping it on every start keeps Nix authoritative; UI changes last until the next restart.
  systemd.user.services.noctalia.Service.ExecStartPre =
    "${pkgs.coreutils}/bin/rm -f %S/noctalia/settings.toml";

  # Both toolkits share the shell's palette. Noctalia owns the generated colors.
  catppuccin.qt5ct.enable = false;
  catppuccin.kvantum.enable = false;
  catppuccin.gtk.icon.enable = false;
  gtk = {
    enable = true;
    font = {
      name = appearance.font;
      size = 11;
    };
    iconTheme = {
      name = appearance.iconTheme;
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraCss = ''@import url("noctalia.css");'';
    gtk4.extraCss = ''@import url("noctalia.css");'';
  };
  dconf.settings."org/gnome/desktop/interface".monospace-font-name = "${appearance.monospaceFont} 11";
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "Fusion";
    qt5ctSettings = qtSettings "5";
    qt6ctSettings = qtSettings "6";
  };

  home.packages = [
    pkgs.adw-gtk3
    pkgs.ddcui
    pkgs.wl-clipboard
  ];
}

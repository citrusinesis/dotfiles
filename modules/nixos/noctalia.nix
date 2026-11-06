{ config, pkgs, ... }:
let
  appearance = import ../../lib/desktop-appearance.nix;
  wallpaper = pkgs.callPackage ../../lib/desktop-wallpaper.nix { };
  toml = pkgs.formats.toml { };
  initialGreeterAppearance = toml.generate "noctalia-greeter-initial-sync.toml" {
    appearance = {
      scheme = "Catppuccin";
      theme_mode = "dark";
      font_family = appearance.font;
    };
  };
in
{
  programs.noctalia = {
    enable = true;
    recommendedServices.enable = true;
  };

  services.displayManager.noctalia-greeter = {
    enable = true;
    # Grant only the packaged appearance-sync operation to the active local user.
    passwordlessSyncUsers = [ config.dotfiles.primaryUser ];
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = appearance.cursorName;
    };
    settings = {
      session.default = "niri";
      user.default = config.dotfiles.primaryUser;
      keyboard.layout = "us";
      cursor.size = appearance.cursorSize;
      # Declared in greeter.toml, which the shell's appearance sync never writes.
      appearance.wallpaper.path = "${wallpaper}";
    };
  };

  systemd.tmpfiles.rules = [
    "C /var/lib/noctalia-greeter/sync.toml 0644 greeter greeter - ${initialGreeterAppearance}"
  ];

  # DDC/CI backs Noctalia's external-monitor brightness control.
  hardware.i2c.enable = true;
  environment.systemPackages = [ pkgs.ddcutil ];
}

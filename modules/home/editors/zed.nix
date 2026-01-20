{ pkgs, ... }:

let
  zedPackage =
    if pkgs.stdenv.isDarwin then
      pkgs.writeShellScriptBin "zed" ''
        exec "/Applications/Zed.app/Contents/Resources/app/bin/zed" "$@"
      ''
    else
      pkgs.unstable.zed-editor;
in
{
  programs.zed-editor = {
    enable = true;
    package = zedPackage;

    extensions = [
      "catppuccin"
      "catppuccin-icons"

      "nix"

      "env"
      "toml"
      "dockerfile"

      "opencode"
    ];

    userSettings = {
      theme = "Catppuccin Mocha - No Italics";
      icon_theme = "Catppuccin Mocha";

      buffer_font_family = "Hack Nerd Font Mono";
      buffer_font_fallbacks = [ "D2CodingLigature Nerd Font" ];
      buffer_font_size = 15;
      ui_font_size = 15;
      colorize_brackets = true;

      load_direnv = "shell_hook";

      terminal = {
        font_family = "Hack Nerd Font Mono";
        font_size = 14;
      };

      format_on_save = "on";
      inlay_hints = {
        enabled = true;
      };

      languages.Nix.language_servers = [
        "nixd"
        "!nil"
      ];
    };
  };
}

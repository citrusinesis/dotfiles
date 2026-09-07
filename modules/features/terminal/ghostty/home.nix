{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.ghostty ];
  # The cask installs the app but does not link a `ghostty` executable into bin.
  home.sessionPath = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "/Applications/Ghostty.app/Contents/MacOS"
  ];

  xdg.configFile."ghostty/config" = {
    force = true;

    text = ''
      theme = Catppuccin ${lib.toSentenceCase config.catppuccin.flavor}

      font-family = "Hack Nerd Font Mono"
      font-family = "Noto Sans Mono CJK KR"
      font-size = 14

      shell-integration = zsh

      cursor-style = block
      cursor-style-blink = false

      window-padding-x = 12
      window-padding-y = 4

      macos-option-as-alt = left
    '';
  };

}

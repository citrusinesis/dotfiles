{ ... }:

{
  imports = [
    ../modules/nix.nix
    ../modules/fonts.nix
    ../modules/shell.nix
    ../modules/base.nix
    ../modules/desktop.nix
    ../modules/nvidia.nix
    ../modules/audio.nix
    ../modules/networking.nix
    ../modules/i18n.nix
    ../modules/power.nix
  ];

  fonts.fontDir = {
    enable = true;
    decompressFonts = true;
  };

  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif CJK KR" "Noto Serif" "Liberation Serif" ];
    sansSerif = [ "Noto Sans CJK KR" "Noto Sans" "Liberation Sans" ];
    monospace = [ "Hack Nerd Font Mono" "GeistMono NF" "Liberation Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };
}

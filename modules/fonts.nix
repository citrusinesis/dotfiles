# Font configuration
{ config, pkgs, lib, ... }:

{
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.geist-mono
    nerd-fonts.d2coding
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
  ];

  # NixOS-specific font configuration
  fonts.fontDir = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    decompressFonts = true;
  };

  fonts.fontconfig = lib.mkIf pkgs.stdenv.isLinux {
    defaultFonts = {
      serif = [ "Noto Serif CJK KR" "Noto Serif" "Liberation Serif" ];
      sansSerif = [ "Noto Sans CJK KR" "Noto Sans" "Liberation Sans" ];
      monospace = [ "Hack Nerd Font Mono" "GeistMono NF" "Liberation Mono" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}

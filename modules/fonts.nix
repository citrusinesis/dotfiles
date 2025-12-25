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
}

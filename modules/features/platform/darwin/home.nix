{ pkgs, ... }:
{
  home.file.".terminfo".source = "${pkgs.ghostty-bin.terminfo}/share/terminfo";
}

{ lib, pkgs, ... }:

{
  programs.zsh.shellAliases = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    open = "${pkgs.xdg-utils}/bin/xdg-open";
    pbcopy = "${pkgs.xclip}/bin/xclip -selection clipboard";
    pbpaste = "${pkgs.xclip}/bin/xclip -selection clipboard -o";
  };

}

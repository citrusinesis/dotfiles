{ lib, pkgs, ... }:

{
  dotfiles.casks = [
    "element"
    "obsidian"
    "paseo"
    "slack"
    "spotify"
  ];

  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.element-desktop
    pkgs.obsidian
    pkgs.llm-agents.paseo-desktop
    pkgs.slack
    pkgs.spotify
  ];
}

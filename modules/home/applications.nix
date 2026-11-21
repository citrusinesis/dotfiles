{ lib, pkgs, ... }:

{
  dotfiles.casks = [
    "chatgpt"
    "claude"
    "element"
    "getoutline"
    "helium-browser"
    "linear"
    "logi-options+"
    "monitorcontrol"
    "obsidian"
    "paseo"
    "raycast"
    "slack"
    "spotify"
    "tailscale-app"
  ];

  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    pkgs.element-desktop
    pkgs.helium-browser
    pkgs.obsidian
    pkgs.llm-agents.paseo-desktop
    pkgs.slack
    pkgs.spotify
  ];
}

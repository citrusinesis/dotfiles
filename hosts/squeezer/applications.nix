{ config, pkgs, lib, ... }:

{
  homebrew = {
    casks = [
      "google-chrome"
      "firefox"
      "jetbrains-toolbox"
      "visual-studio-code"
      "figma"
      "slack"
      "notion"
      "obsidian"
      "raycast"
      "tailscale-app"
      "ghostty"
      "logi-options+"
      "cloudflare-warp"
      "monitorcontrol"
    ];

    brews = [];

    masApps = {
      "KakaoTalk" = 869223134;
      "RunCat" = 1429033973;
    };
  };
}

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
      "ghostty"

      "claude"

      "tailscale-app"
      "cloudflare-warp"
      
      "logi-options+"
      "monitorcontrol"
    ];

    brews = [
      "opencode"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
      "RunCat" = 1429033973;
    };
  };
}

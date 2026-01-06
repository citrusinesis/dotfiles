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
      "element"

      "raycast"
      "ghostty"

      "claude"
      "codex"

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

{ lib, ... }:

{
  homebrew = {
    taps = [
      "anomalyco/tap"
    ];

    casks = [
      "google-chrome"
      "helium-browser"

      "slack"
      "obsidian"
      "element"
      "raycast"

      "zed"
      "ghostty"
      "orbstack"
      "tailscale-app"
      "mongodb-compass"

      "claude"
      "codex-app"
      "chatgpt"

      "logi-options+"
    ];

    brews = [
      "mas"
      # "opencode"
      "mole"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
      "RunCat" = 1429033973;
    };
  };
}

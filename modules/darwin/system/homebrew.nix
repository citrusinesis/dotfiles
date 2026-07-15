{ ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
      extraFlags = [ "--force-cleanup" ];
    };

    taps = [
      "anomalyco/tap"
    ];

    # Casks shared by every darwin host; host-specific extras live in
    # configurations/darwin/<host>/applications.nix.
    casks = [
      "helium-browser"

      "slack"

      "raycast"

      "claude"
      "chatgpt"

      "tailscale-app"

      "logi-options+"
    ];

    brews = [
      "mas"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
      "RunCat Neo" = 6757801838;
    };
  };
}

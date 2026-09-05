{ ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };

    taps = [
      "anomalyco/tap"
    ];

    brews = [
      "mas"
    ];

  };
}

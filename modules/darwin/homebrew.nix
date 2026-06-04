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
  };
}

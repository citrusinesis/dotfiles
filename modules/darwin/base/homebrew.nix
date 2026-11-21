{ config, lib, ... }:

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

    # Home modules declare the casks for the applications they configure.
    casks = lib.concatMap (home: home.dotfiles.casks) (lib.attrValues config.home-manager.users);
  };
}

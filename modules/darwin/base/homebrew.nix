{ config, lib, ... }:

{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };

    taps = [
      "anomalyco/tap"
    ];

    brews = [
      "mas"
      "mole"
    ];

    masApps = {
      "KakaoTalk" = 869223134;
      "RunCat Neo" = 6757801838;
    };

    # Home modules declare the casks for the applications they configure.
    casks = lib.concatMap (home: home.dotfiles.casks) (lib.attrValues config.home-manager.users);
  };
}

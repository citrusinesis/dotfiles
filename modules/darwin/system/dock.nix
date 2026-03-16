{ ... }:

{
  system.defaults = {
    dock = {
      autohide = false;
      expose-group-apps = true;
      launchanim = true;
      mineffect = "genie";
      minimize-to-application = true;
      mru-spaces = false;
      orientation = "bottom";
      show-recents = false;
      showhidden = true;
      static-only = true;
      tilesize = 50;

      # Hot corners — all disabled (1 = disabled)
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };

    spaces.spans-displays = false;

    CustomUserPreferences.".GlobalPreferences".AppleSpacesSwitchOnActivate = true;
  };
}

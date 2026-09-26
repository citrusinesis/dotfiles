{ lib, ... }:

{
  # Shared preferences; account modules may override individual keys.
  system.defaults = {
    dock = {
      expose-group-apps = lib.mkDefault true;
      launchanim = lib.mkDefault true;
      mineffect = lib.mkDefault "genie";
      minimize-to-application = lib.mkDefault true;
      mru-spaces = lib.mkDefault false;
      orientation = lib.mkDefault "bottom";
      show-recents = lib.mkDefault false;
      showhidden = lib.mkDefault true;
      static-only = lib.mkDefault true;
      tilesize = lib.mkDefault 50;
      wvous-bl-corner = lib.mkDefault 1;
      wvous-br-corner = lib.mkDefault 1;
      wvous-tl-corner = lib.mkDefault 1;
      wvous-tr-corner = lib.mkDefault 1;
    };

    spaces = {
      spans-displays = lib.mkDefault false;
    };
  };
}

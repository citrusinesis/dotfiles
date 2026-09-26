{
  imports = [ ./preferences.nix ];

  homebrew = {
    casks = [ "mongodb-compass" ];
    brews = [
      "mole"
    ];
  };
}

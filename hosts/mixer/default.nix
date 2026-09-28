{ modules, ... }:
{
  imports = [
    modules.darwin.default
    modules.darwin.apple-container
    modules.darwin.applications
    modules.system.fonts
    ./preferences.nix
  ];

  time.timeZone = "Asia/Seoul";

  pf = {
    screen-sharing = {
      enable = true;
      high-performance = true;
    };
    ssh.enable = true;
  };

  power = {
    sleep = {
      computer = "never";
      display = "never";
      harddisk = "never";

      allowSleepByPowerButton = true;
    };

    restartAfterFreeze = true;
    restartAfterPowerFailure = true;
  };

  homebrew = {
    casks = [ "mongodb-compass" ];
    brews = [
      "mole"
    ];
  };
}

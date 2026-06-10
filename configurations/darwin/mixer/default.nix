{ flake, ... }:

{
  imports = [
    flake.inputs.self.darwinModules.default
    ./applications.nix
  ];

  networking.hostName = "mixer";

  containerRuntime = "orbstack";

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
}

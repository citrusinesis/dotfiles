{ config, pkgs, ... }:

{
  homebrew = {
    brews = [
      "mole"
    ];
  };

  home-manager.users.${config.system.primaryUser}.home.packages = with pkgs; [
    mongodb-compass
  ];
}

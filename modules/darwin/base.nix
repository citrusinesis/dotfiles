{
  flake,
  lib,
  pkgs,
  ...
}:

let
  inherit (flake.inputs) self;
  personal = import (self + /personal.nix);
  username = personal.user.username;
in

{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  system = {
    primaryUser = username;
    stateVersion = 5;
  };

  time.timeZone = personal.timezone;

  networking.knownNetworkServices = lib.mkDefault [
    "Wi-Fi"
    "Ethernet"
  ];

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  home-manager = {
    backupFileExtension = "bak";
    users.${username} = import (self + /configurations/home/default);
    extraSpecialArgs = { inherit username; };
  };

  environment.systemPackages = with pkgs; [
    coreutils
  ];
}

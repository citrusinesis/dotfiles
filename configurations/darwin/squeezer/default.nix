{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  personal = import (self + /personal.nix);
  username = personal.user.username;
in
{
  imports = [
    self.darwinModules.default
    (self + /modules/shared/nix.nix)
    (self + /modules/shared/fonts.nix)
    ./applications.nix
    inputs.home-manager.darwinModules.home-manager
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.overlays = [ self.overlays.default ];
  nixpkgs.config.allowUnfree = true;

  networking.hostName = "squeezer";
  networking.knownNetworkServices = [
    "Wi-Fi"
    "Ethernet"
  ];
  time.timeZone = personal.timezone;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    users.${username} = import (self + /configurations/home/citrus);
    extraSpecialArgs = { inherit flake; };
  };
}

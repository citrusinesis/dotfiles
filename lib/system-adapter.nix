{
  host,
  accounts,
  pkgs,
}:
{ config, lib, ... }:
let
  primaryUser = (builtins.head (lib.filter (a: a.id == host.primaryAccount) accounts)).userName;
in
{
  options.dotfiles.primaryUser = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    description = "Login name of this Host's primaryAccount.";
  };
  config = {
    dotfiles.primaryUser = primaryUser;
    nixpkgs = {
      inherit pkgs;
      hostPlatform = host.system;
    };
    networking = {
      hostName = lib.mkForce host.name;
    }
    // lib.optionalAttrs (host.backend == "darwin") { localHostName = lib.mkForce host.name; };
    users.users = builtins.listToAttrs (
      map (a: {
        name = a.userName;
        value = {
          name = lib.mkForce a.userName;
          home = lib.mkForce a.home.directory;
        };
      }) accounts
    );
    assertions = [
      {
        assertion = config.nixpkgs.overlays == [ ];
        message = "Host ${host.name}: keep overlays in the shared package import in lib/mk-configurations.nix";
      }
    ];
  }
  // lib.optionalAttrs (host.backend == "darwin") {
    system.primaryUser = primaryUser;
    homebrew.caskArgs.appdir = "/Applications";
  }
  // {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupCommand = lib.getExe (import ./home-manager-backup.nix { inherit pkgs; });
      users = builtins.listToAttrs (
        map (a: {
          name = a.userName;
          value.imports = a.homeModules;
        }) accounts
      );
    };
  };
}

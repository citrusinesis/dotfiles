{ inputs, lib }:
{
  name,
  system,
  user,
  stateVersion,
}:
let
  darwin = lib.hasSuffix "-darwin" system;
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ inputs.self.overlays.default ];
  };
  specialArgs = {
    inherit inputs;
  };
  homeDirectory = "${if darwin then "/Users" else "/home"}/${user}";
  homeModules = [
    ../hosts/${name}/home.nix
    {
      home = {
        username = user;
        inherit homeDirectory stateVersion;
      };
    }
  ];

  hostModule = {
    options.dotfiles.primaryUser = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Login name of the user who owns this host.";
    };

    config = {
      dotfiles.primaryUser = user;
      nixpkgs = {
        inherit pkgs;
        hostPlatform = system;
      };
      networking = {
        hostName = lib.mkForce name;
      }
      // lib.optionalAttrs darwin { localHostName = lib.mkForce name; };
      users.users.${user}.home = lib.mkForce homeDirectory;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        overwriteBackup = true;
        extraSpecialArgs = specialArgs;
        users.${user}.imports = homeModules;
      };
    }
    // lib.optionalAttrs darwin {
      system.primaryUser = user;
      homebrew.caskArgs.appdir = "/Applications";
    };
  };
in
(if darwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem) {
  inherit specialArgs;
  modules = [
    ../hosts/${name}
    (
      if darwin then
        inputs.home-manager.darwinModules.home-manager
      else
        inputs.home-manager.nixosModules.home-manager
    )
    hostModule
  ];
}

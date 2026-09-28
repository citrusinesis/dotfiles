{ inputs, lib }:
# Builds a host's system from hosts/<name>/default.nix and its user's Home from
# hosts/<name>/home.nix, both as integrated Home and as standalone Home.
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
    modules = import ./modules.nix { inherit lib; };
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

  hostModule =
    { config, ... }:
    {
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
        assertions = [
          {
            assertion = config.nixpkgs.overlays == [ ];
            message = "Host ${name}: keep overlays in the shared package import in lib/mk-host.nix";
          }
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          backupCommand = lib.getExe (import ./home-manager-backup.nix { inherit pkgs; });
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
{
  system = (if darwin then inputs.nix-darwin.lib.darwinSystem else inputs.nixpkgs.lib.nixosSystem) {
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
  };

  home = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = homeModules;
    extraSpecialArgs = specialArgs;
  };
}

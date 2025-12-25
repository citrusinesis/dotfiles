{
  description = "Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, darwin, home-manager, home-manager-unstable, flake-utils, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      personal = import ./personal.nix;
      overlays = import ./overlays { inherit inputs; };

      mkNixosConfig = { system, hostName, username, modules ? [] }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs username; };
          modules = [
            { nixpkgs.overlays = builtins.attrValues overlays; }
            ./hosts/${hostName}
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/${username};
              home-manager.extraSpecialArgs = { inherit inputs username; };
            }
          ] ++ modules;
        };

      mkDarwinConfig = { system, hostName, username, modules ? [] }:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = { inherit inputs username; };
          modules = [
            { nixpkgs.overlays = builtins.attrValues overlays; }
            ./hosts/${hostName}
            home-manager-unstable.darwinModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/${username};
              home-manager.extraSpecialArgs = { inherit inputs username; };
            }
          ] ++ modules;
        };
    in {
      nixosConfigurations.blender = mkNixosConfig {
        system = "x86_64-linux";
        hostName = "blender";
        username = personal.user.username;
      };

      darwinConfigurations.squeezer = mkDarwinConfig {
        system = "aarch64-darwin";
        hostName = "squeezer";
        username = personal.user.username;
      };

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nixpkgs-fmt
              nil
            ];
          };
        }
      );
    };
}

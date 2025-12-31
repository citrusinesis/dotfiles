{
  description = "Nix Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      darwin,
      home-manager,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      personal = import ./personal.nix;
      overlays = import ./overlays { inherit inputs; };
      lib = import ./lib.nix { inherit inputs overlays; };
    in
    {
      nixosConfigurations.blender =
        lib.mkNixosConfig
          {
            nixpkgs = nixpkgs;
            home-manager = home-manager;
          }
          {
            system = "x86_64-linux";
            hostName = "blender";
            username = personal.user.username;
          };

      darwinConfigurations.squeezer =
        lib.mkDarwinConfig
          {
            darwin = darwin;
            home-manager = home-manager;
          }
          {
            system = "aarch64-darwin";
            hostName = "squeezer";
            username = personal.user.username;
          };
    };
}

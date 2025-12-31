{ inputs, overlays }:

{
  mkNixosConfig =
    { nixpkgs, home-manager }:
    {
      system,
      hostName,
      username,
      modules ? [ ],
    }:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs username; };
      modules = [
        { nixpkgs.overlays = builtins.attrValues overlays; }
        ./hosts/${hostName}
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.${username} = import ./home/${username};
          home-manager.extraSpecialArgs = { inherit inputs username; };
        }
      ]
      ++ modules;
    };

  mkDarwinConfig =
    { darwin, home-manager }:
    {
      system,
      hostName,
      username,
      modules ? [ ],
    }:
    darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs username; };
      modules = [
        { nixpkgs.overlays = builtins.attrValues overlays; }
        ./hosts/${hostName}
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.users.${username} = import ./home/${username};
          home-manager.extraSpecialArgs = { inherit inputs username; };
        }
      ]
      ++ modules;
    };
}

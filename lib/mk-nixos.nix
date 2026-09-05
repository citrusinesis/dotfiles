{ inputs }:
{ aspect, username }:
inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.nixosModules.home-manager
    (aspect.resolve { class = "nixos"; })
    {
      dotfiles.primaryUser = username;
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs; };
        users.${username}.imports = [ (aspect.resolve { class = "homeManager"; }) ];
      };
    }
  ];
}

{ inputs }:
{ aspect, username }:
inputs.nix-darwin.lib.darwinSystem {
  specialArgs = { inherit inputs; };
  modules = [
    inputs.home-manager.darwinModules.home-manager
    (aspect.resolve { class = "darwin"; })
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

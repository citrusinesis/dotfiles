{
  dotfiles.aspects.features.provides.core = {
    darwin = ./system.nix;
    nixos = ./system.nix;
    homeManager = ./home.nix;
  };
}

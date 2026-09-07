{
  dotfiles.aspects.features.provides.fonts = {
    nixos = ./system.nix;
    darwin = ./system.nix;
    homeManager = ./home.nix;
  };
}

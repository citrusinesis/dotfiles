{ flake, ... }:

let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.base
    self.homeModules.development
  ];

  dotfiles.home.gui.enable = true;
}

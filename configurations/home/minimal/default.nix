{ flake, ... }:

let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.base
    self.homeModules.minimal
  ];

  dotfiles.home.gui.enable = true;
}

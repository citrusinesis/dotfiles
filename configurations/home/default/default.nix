{ flake, ... }:

let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.base
    self.homeModules.default
  ];

  dotfiles.home.gui.enable = true;
}

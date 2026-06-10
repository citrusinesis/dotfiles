{ flake, ... }:

let
  inherit (flake.inputs) self;
in
{
  imports = [
    self.homeModules.base
    self.homeModules.headless
  ];
}

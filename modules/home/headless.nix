{ flake, ... }:

{
  imports = [
    flake.inputs.nixvim.homeModules.nixvim
    ./minimal.nix
    ./editors/nixvim
  ];
}

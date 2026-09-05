{ inputs, lib, ... }:
{
  imports = [
    ((inputs.flake-aspects.lib lib).new-scope "dotfiles")
    ./flake
    ./features
    ./profiles
    ./hosts
  ];
}

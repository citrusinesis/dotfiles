{ inputs, lib, ... }:
{
  imports = [
    ((inputs.flake-aspects.lib lib).new-scope "dotfiles")
    ./inventory.nix
    ./flake
    ./features
    ./users
    ./hosts
    ./accounts
  ];
}

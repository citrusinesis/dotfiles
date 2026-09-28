{ inputs, ... }:

{
  imports = [
    inputs.nix-index-database.homeModules.default
    ../theme.nix
    ./atuin.nix
    ./bat.nix
    ./btop.nix
    ./eza.nix
    ./fd.nix
    ./packages.nix
    ./ripgrep.nix
    ./ssh.nix
    ./yazi.nix
  ];
}

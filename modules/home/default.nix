{ lib, ... }:
{
  imports = [
    ./activation.nix
    ./core.nix
    ./identity.nix
    ./cli
    ./shell
    ./languages
    ./tools
    ./nixvim
  ];

  options.dotfiles.casks = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Homebrew casks that nix-darwin installs for this Home's applications.";
  };
}

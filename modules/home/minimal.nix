{
  flake,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    flake.inputs.nix-index-database.homeModules.default

    ./cli/module.nix
    ./shell/module.nix
    ./languages/nix.nix
    ./dev/direnv.nix
    ./dev/git.nix
    ./dev/gpg.nix
  ];

  home.packages = [ (lib.lowPrio pkgs.vim) ];
  home.sessionVariables = {
    EDITOR = lib.mkDefault "vim";
    VISUAL = lib.mkDefault "vim";
  };
}

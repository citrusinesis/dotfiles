{ lib, pkgs, ... }:

{
  imports = [
    ./cli/module.nix
    ./shell/module.nix
    ./languages/nix.nix
    ./dev/direnv.nix
    ./dev/git.nix
  ];

  home.packages = [ (lib.lowPrio pkgs.vim) ];
  home.sessionVariables = {
    EDITOR = lib.mkDefault "vim";
    TERM = "xterm-256color";
    VISUAL = lib.mkDefault "vim";
  };
}

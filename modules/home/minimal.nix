{ ... }:

{
  imports = [
    ./cli
    ./shell

    ./terminals/ghostty.nix

    ./editors/vscode.nix

    ./languages/nix.nix
    ./dev/direnv.nix
    ./dev/git.nix
  ];
}

{ ... }:

{
  imports = [
    ./cli
    ./shell

    ./editors/neovim.nix

    ./languages

    ./dev/agents.nix
    ./dev/direnv.nix
    ./dev/git.nix
    ./dev/kubernetes.nix
    ./dev/podman.nix
    ./dev/teleport.nix
  ];
}

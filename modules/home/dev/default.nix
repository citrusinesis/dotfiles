{ ... }:

{
  imports = [
    ./git.nix
    ./direnv.nix
    ./podman.nix
    ./kubernetes.nix
    ./teleport.nix
  ];
}

{ ... }:

{
  imports = [
    ./headless.nix
    ./languages/module.nix
    ./dev/agents.nix
    ./dev/apple-container.nix
    ./dev/kubernetes.nix
    ./dev/podman.nix
    ./dev/teleport.nix
  ];
}

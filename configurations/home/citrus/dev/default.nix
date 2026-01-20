{ ... }:

let
  localFile = ./teleport-local.nix;
in
{
  imports = [
    ./git.nix
    ./direnv.nix
    ./podman.nix
    ./kubernetes.nix
    ./teleport.nix
  ] ++ (if builtins.pathExists localFile then [ localFile ] else [ ]);
}

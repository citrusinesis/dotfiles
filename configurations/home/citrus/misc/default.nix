{ ... }:

let
  localFile = ./ssh-local.nix;
in
{
  imports = [
    ./ssh.nix
    ./opencode.nix
    ./apps.nix
    ./torrent.nix
  ] ++ (if builtins.pathExists localFile then [ localFile ] else [ ]);
}

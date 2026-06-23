{
  pkgs,
  lib,
  targetSystem ? null,
}:

import ../apple-container-nixos-machine/rootfs.nix {
  inherit pkgs lib targetSystem;
}

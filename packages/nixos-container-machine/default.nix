{
  pkgs,
  lib,
  targetSystem ? null,
}:

import ../apple-container-machine/rootfs.nix {
  inherit pkgs lib targetSystem;
}

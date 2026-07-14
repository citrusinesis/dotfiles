{ lib, ... }:

{
  imports = [
    ./nix.nix
    ./cache.nix
  ];

  time.timeZone = lib.mkDefault "UTC";

  programs.zsh.enable = true;
}

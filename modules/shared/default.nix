{ lib, ... }:

{
  imports = [
    ./nix.nix
    ./fonts.nix
    ./cache.nix
  ];

  time.timeZone = lib.mkDefault "UTC";

  programs.zsh.enable = true;
}

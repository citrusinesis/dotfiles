{ lib, ... }:

{
  imports = [
    ./nix.nix
    ./fonts.nix
  ];

  time.timeZone = lib.mkDefault "UTC";

  programs.zsh.enable = true;
}

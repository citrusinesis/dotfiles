{ lib, ... }:

{
  imports = [
    ./nix.nix
    ./cache.nix
  ];

  time.timeZone = lib.mkDefault "Asia/Seoul";

  programs.zsh.enable = true;
}

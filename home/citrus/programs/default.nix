{ config, lib, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./zsh.nix
    ./ssh.nix
    ./direnv.nix
    ./starship.nix
    ./vscode.nix
    ./kitty.nix
    ./neovim.nix
    ./podman.nix
    ./ghostty.nix
    ./opencode.nix
  ];
}

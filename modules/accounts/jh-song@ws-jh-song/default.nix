{ ... }:
{
  dotfiles.inventory.accounts."jh-song@ws-jh-song" = {
    home = {
      stateVersion = "25.11";
    };
    aspect = {
      nixos = ./nixos.nix;
    };
  };
}

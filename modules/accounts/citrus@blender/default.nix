{ ... }:
{
  dotfiles.inventory.accounts."citrus@blender" = {
    home = {
      stateVersion = "25.11";
    };
    aspect = {
      nixos = ./nixos.nix;
    };
  };
}

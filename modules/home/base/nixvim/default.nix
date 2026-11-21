{ inputs, ... }:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./core.nix
    ./filetypes.nix
    ./go.nix
    ./keymaps.nix
    ./lsp.nix
    ./plugins.nix
    ./rust.nix
    ./snacks.nix
    ./tabs.nix
    ./treesitter.nix
  ];
}

{ inputs, lib, ... }:

{
  flake.homeModules = lib.genAttrs [ "default" "development" "headless" ] (_: {
    imports = [
      inputs.nixvim.homeModules.nixvim
    ];
  });
}

{ inputs, ... }:

{
  flake.homeModules = {
    default = [
      inputs.nixvim.homeModules.nixvim
    ];

    development = [
      inputs.nixvim.homeModules.nixvim
    ];

    headless = [
      inputs.nixvim.homeModules.nixvim
    ];
  };
}

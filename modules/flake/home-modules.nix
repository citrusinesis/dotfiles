{ inputs, ... }:

{
  flake.homeModules = {
    default = {
      imports = [
        inputs.nixvim.homeModules.nixvim
      ];
    };

    development = {
      imports = [
        inputs.nixvim.homeModules.nixvim
      ];
    };

    headless = {
      imports = [
        inputs.nixvim.homeModules.nixvim
      ];
    };
  };
}

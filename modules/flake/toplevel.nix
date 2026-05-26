{ inputs, ... }:

{
  imports = [
    inputs.nixos-unified.flakeModules.default
    inputs.nixos-unified.flakeModules.autoWire
    inputs.home-manager.flakeModules.home-manager
  ];

  perSystem =
    { self', pkgs, ... }:
    {
      formatter = pkgs.nixfmt;
      packages.default = self'.packages.activate;
    };
}

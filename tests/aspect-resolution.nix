{ inputs, lib }:
let
  aspects =
    (lib.evalModules {
      modules = [
        ((inputs.flake-aspects.lib lib).new-scope "test")
        (
          { config, ... }:
          let
            a = config.test.aspects;
          in
          {
            test.aspects = {
              features.provides.leaf = {
                homeManager = ./fixtures/selected.nix;
                nixos = ./fixtures/selected.nix;
              };
              left.includes = [ a.features.provides.leaf ];
              right.includes = [ a.features.provides.leaf ];
              host.includes = [
                a.left
                a.right
              ];
            };
          }
        )
      ];
    }).config.test.aspects;
  evaluate =
    class: aspect:
    (lib.evalModules {
      inherit class;
      modules = [
        {
          options.selected = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        }
        (aspect.resolve { inherit class; })
      ];
    }).config.selected;
in
{
  composition-only = !(aspects.host.modules ? homeManager);
  home-resolution-and-deduplication = evaluate "homeManager" aspects.host == [ "homeManager" ];
  nixos-resolution-and-deduplication = evaluate "nixos" aspects.host == [ "nixos" ];
  namespace-is-not-selection = evaluate "homeManager" aspects.features == [ ];
}

{ lib, ... }:
let
  inherit (lib) mkOption types;
  aspect = mkOption {
    type = types.raw;
    default = { };
    description = "Aspect composed from selected features and ordinary Nix modules.";
  };
in
{
  options.dotfiles.inventory = {
    users = mkOption {
      default = { };
      type = types.attrsOf (types.submodule { options = { inherit aspect; }; });
    };
    hosts = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule (
          { config, ... }: {
            options = {
              inherit aspect;
              system = mkOption { type = types.strMatching ".+-(darwin|linux)"; };
              backend = mkOption {
                type = types.enum [
                  "nixos"
                  "darwin"
                  "unmanaged"
                ];
              };
              primaryAccount =
                mkOption {
                  type = if config.backend == "unmanaged" then types.enum [ null ] else types.str;
                }
                // lib.optionalAttrs (config.backend == "unmanaged") { default = null; };
            };
          }
        )
      );
    };
    accounts = mkOption {
      default = { };
      type = types.attrsOf (
        types.submodule {
          options = {
            inherit aspect;
            home = {
              directory = mkOption {
                type = types.nullOr (types.strMatching "/.*");
                default = null;
              };
              stateVersion = mkOption { type = types.str; };
            };
          };
        }
      );
    };
  };
}

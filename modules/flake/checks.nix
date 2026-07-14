{
  lib,
  self,
  ...
}:

{
  perSystem =
    { pkgs, system, ... }:
    let
      evaluationCheck =
        name: drvPath:
        pkgs.runCommand name { evaluated = builtins.unsafeDiscardStringContext drvPath; } ''
          printf '%s\n' "$evaluated" > "$out"
        '';

      homeChecks = lib.mapAttrs' (
        name: configuration:
        lib.nameValuePair "home-${name}-evaluation" (
          evaluationCheck "home-${name}-evaluation" configuration.activationPackage.drvPath
        )
      ) self.legacyPackages.${system}.homeConfigurations;

      darwinChecks = lib.optionalAttrs (system == "aarch64-darwin") (
        lib.mapAttrs' (
          name: configuration:
          lib.nameValuePair "darwin-${name}-evaluation" (
            evaluationCheck "darwin-${name}-evaluation" configuration.system.drvPath
          )
        ) self.darwinConfigurations
      );

      nixosChecks = lib.optionalAttrs (system == "x86_64-linux") (
        lib.mapAttrs' (
          name: configuration:
          lib.nameValuePair "nixos-${name}-evaluation" (
            evaluationCheck "nixos-${name}-evaluation" configuration.config.system.build.toplevel.drvPath
          )
        ) self.nixosConfigurations
      );
    in
    {
      checks = homeChecks // darwinChecks // nixosChecks;
    };
}

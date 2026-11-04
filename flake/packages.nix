{ inputs, ... }:

{
  flake.overlays.default = import ../overlays { inherit inputs; };

  perSystem =
    {
      config,
      lib,
      system,
      ...
    }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.self.overlays.default ];
        config.allowUnfree = true;
      };
    in
    {
      _module.args.pkgs = pkgs;

      formatter = pkgs.nixfmt;
      packages = {
        inherit (pkgs) nh;
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        inherit (pkgs) helium-browser;
      };

      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          bash
          gitleaks
          shellcheck
        ];
        shellHook = config.pre-commit.installationScript;
      };
    };
}

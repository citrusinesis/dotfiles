{ inputs, ... }:

{
  flake.overlays.default = import ../../overlays { inherit inputs; };

  perSystem =
    {
      config,
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
      packages.nh = pkgs.nh;

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

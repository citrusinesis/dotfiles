{ inputs, ... }:

{
  flake.overlays.default = import ../overlays { inherit inputs; };

  perSystem =
    { lib, system, ... }:
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
      packages = lib.filterAttrs (_: lib.meta.availableOn pkgs.stdenv.hostPlatform) {
        inherit (pkgs) helium-browser;
      };
    };
}

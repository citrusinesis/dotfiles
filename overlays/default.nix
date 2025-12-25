# This file contains custom overlays to extend nixpkgs

{ inputs, ... }:

{
  # Unstable packages overlay
  # Provides access to nixpkgs-unstable packages via pkgs.unstable.package-name
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}

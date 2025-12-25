{ inputs, ... }:

{
  # NixOS uses nixpkgs-darwin for unstable packages overlay
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-darwin {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}

{ flake, ... }:
let
  inherit (flake) inputs;
in
final: prev:
(inputs.fenix.overlays.default final prev)
// (inputs.nix-vscode-extensions.overlays.default final prev)
// (inputs.llm-agents.overlays.shared-nixpkgs final prev)
// (inputs.nixvim.overlays.default final prev)
// {
  # Compatibility for inputs that still access the deprecated platform aliases.
  # Remove this once nixos-unified and nixvim use stdenv.hostPlatform directly.
  stdenv = prev.stdenv // {
    isDarwin = prev.stdenv.hostPlatform.isDarwin;
    isLinux = prev.stdenv.hostPlatform.isLinux;
  };

  dotfilesPackages = {
    apple-container = final.callPackage ../packages/apple-container/package.nix {
      inherit (prev) container;
    };
  };
}

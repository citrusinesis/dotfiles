{ inputs }:
final: prev:
(inputs.fenix.overlays.default final prev)
// (inputs.nix-vscode-extensions.overlays.default final prev)
// (inputs.llm-agents.overlays.shared-nixpkgs final prev)
// (inputs.nixvim.overlays.default final prev)
// {
  dotfilesPackages = {
    apple-container = final.callPackage ../packages/apple-container/package.nix {
      inherit (prev) container;
    };
  };
}

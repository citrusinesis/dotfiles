{ flake, ... }:

let
  inherit (flake) inputs;
in

final: prev:
(inputs.fenix.overlays.default final prev)
// (inputs.nix-vscode-extensions.overlays.default final prev)
// (inputs.llm-agents.overlays.default final prev)
// (inputs.nixvim.overlays.default final prev)
// {
  apple-container = final.callPackage ../packages/apple-container { };
}

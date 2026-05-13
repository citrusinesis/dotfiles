{ inputs, ... }:

{
  flake.overlays.default =
    final: prev:
    (inputs.fenix.overlays.default final prev)
    // (inputs.nix-vscode-extensions.overlays.default final prev)
    // (inputs.llm-agents.overlays.default final prev)
    // {
      direnv = prev.direnv.overrideAttrs (_: {
        doCheck = false;
      });
    };
}

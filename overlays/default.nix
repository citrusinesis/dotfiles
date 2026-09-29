{ inputs }:
final: prev:
(inputs.fenix.overlays.default final prev) // (inputs.llm-agents.overlays.shared-nixpkgs final prev)

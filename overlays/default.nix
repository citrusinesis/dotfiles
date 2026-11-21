{ inputs }:
final: prev:
(inputs.fenix.overlays.default final prev)
// {
  llm-agents = inputs.llm-agents.packages.${final.stdenv.hostPlatform.system};

  helium-browser = final.callPackage ../pkgs/helium { };
}

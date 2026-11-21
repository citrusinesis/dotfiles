{
  inputs,
  final,
  prev,
}:
let
  packages = (inputs.llm-agents.overlays.shared-nixpkgs final prev).llm-agents;
in
packages
// {
  codex = packages.codex.override {
    aws-lc = (final.aws-lc.override { withOpenSSLShim = true; }).overrideAttrs { doCheck = false; };
  };
}

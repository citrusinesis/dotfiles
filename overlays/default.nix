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

  # nix-update evaluates flakes with nix-instantiate, which defaults to a
  # read-only store and cannot materialize lazy flake source paths.
  nix-update = prev.nix-update.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace nix_update/eval.py \
        --replace-fail \
          '        "--eval",' \
          '        "--eval", "--read-write-mode",'
    '';
  });

  dotfilesPackages = {
    # Pin upstream because nixpkgs lags behind releases.
    apple-container = final.callPackage ../packages/apple-container/package.nix {
      inherit (prev) container;
    };
  };
}

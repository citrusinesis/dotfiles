{ inputs }:
final: prev:
(inputs.fenix.overlays.default final prev)
// (inputs.llm-agents.overlays.shared-nixpkgs final prev)
// {
  # nixos-unstable's Lix 2.95.3 passes the ELF-only `-z,noexecstack` to ld64,
  # so it cannot link on Darwin. Fixed on nixpkgs master; drop this once the
  # nixpkgs pin carries the fix.
  lixPackageSets = prev.lixPackageSets.extend (
    _: lixPrev: {
      lix_2_95 = lixPrev.lix_2_95.overrideScope (
        _: scopePrev: {
          lix = scopePrev.lix.overrideAttrs (old: {
            env = old.env // {
              NIX_LDFLAGS = prev.lib.optionalString prev.stdenv.hostPlatform.isElf "-z,noexecstack";
            };
          });
        }
      );
    }
  );
}

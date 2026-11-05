# Rule: Development Environment

When a project needs a pinned toolchain or a reproducible dev environment, provide it through a Nix flake with a devShell — not through global or per-user installers (`rustup`, `brew install`, `pip install --user`, `npm -g`).
A flake pins the toolchain per project, reproduces across machines, and leaves the host clean.

This is about how you provision a toolchain when a project warrants one; it is not a mandate to Nixify a throwaway repo.

- Structure the flake with `flake-parts` (`flake-parts.lib.mkFlake`) and a `perSystem` block, rather than hand-rolling `eachSystem` or `flake-utils`.
- Declare the toolchain and tools in `devShells.default` via `pkgs.mkShell`.
- Pin `nixpkgs` (e.g. `nixos-unstable`) and make every other input `follows` `nixpkgs`, so the lockfile keeps a single nixpkgs.
- List only the systems you actually target in `systems` (e.g. `x86_64-linux`, `aarch64-linux`, `aarch64-darwin`).
- Classify each dependency by the role it plays, not by whichever list is closest to hand. `pkgs.mkShell` appends `packages` to `nativeBuildInputs`, so the two are the same list; the distinction that carries weight is against `buildInputs`.
  - `packages` — plain dev tools that only need to be on `PATH` in the shell: the toolchain, `cargo-watch`, `jq`.
  - `nativeBuildInputs` — tools the build itself invokes: `pkg-config`, `cmake`, codegen. Prefer this over `packages` once a shell also carries `buildInputs`, so the split stays visible.
  - `buildInputs` — libraries the code links against: `openssl`, `zlib`, `libiconv`. Never route these through `packages`: nixpkgs splices `nativeBuildInputs` to the build platform, so under cross-compilation you would link the host's copy instead of the target's.
- When the flake already defines a build target, derive the shell from it with `inputsFrom = [ self'.packages.default ]` instead of restating its dependency list. `inputsFrom` merges every input category from the referenced derivations and concatenates their `shellHook`s; layer dev-only extras (`rust-analyzer`, `cargo-watch`) on top through `packages`.
- Prefer a Nix build target over a parallel container recipe. When a project needs an image, build it with `pkgs.dockerTools.buildLayeredImage` from the package derivation rather than maintaining a `Dockerfile` — a Dockerfile re-declares dependencies outside the flake and drifts from it — and let the devShell `inputsFrom` that same derivation so the shell and the image cannot disagree.

## Rust specifics

- Use `fenix` for the Rust toolchain, not `rustup`. `rustup` manages a mutable global toolchain; `fenix` gives a pinned, declarative one inside the flake.
- Compose the toolchain with `fenix.combine [ ... ]`, including `rustc`, `cargo`, `clippy`, `rustfmt`, `rust-src`, and `rust-analyzer`.
- Choose the channel deliberately: `fenix.stable.*` for released work, `fenix.complete.*` (nightly) only when a feature needs it.
  Prefer `complete` over `latest` for nightly. `complete` takes every component from a single date; `latest` mixes components across dates and accepts a higher chance of incompatibility.
- Take `rustfmt` from nightly (`fenix.complete.rustfmt`) even when the rest of the toolchain is stable — a standing exception to the channel rule above.
  The `rustfmt.toml` options worth having are all nightly-gated: `wrap_comments`, `format_code_in_doc_comments`, `comment_width`, `imports_granularity`, `group_imports`, `normalize_comments`.
  `wrap_comments` is the one that lets `cargo fmt` own comment width, which `line-breaks.md` in this directory depends on: stable rustfmt never wraps comments, so that rule has no formatter to hand column width to.
  Mixing channels inside a single `fenix.combine` is what makes this painless — plain `cargo fmt` picks up the nightly `rustfmt`, with no second toolchain and no `cargo +nightly fmt`.
- Do not extend that exception to `cargo` or `clippy`; take both from the same channel as `rustc`.
  `clippy-driver` dynamically links one exact `librustc_driver-<hash>`, and that hash changes with every `rustc` build, so a nightly clippy against a stable `rustc` fails to load outright. Nightly clippy means going fully nightly.
  Nightly `cargo` does run against a stable `rustc`, but buys little: the `-Z` flags worth having need nightly `rustc` anyway, and cargo's unstable surface keeps stabilizing.
  `rustfmt` is the exception precisely because it is a standalone binary that links no rustc internals, and its options have stayed unstable for years.
- Add cross targets (`fenix.targets.<triple>.stable.rust-std`) only when the project actually cross-compiles. When cross-compiling (e.g. to `*-musl`), take the cross `stdenv.cc` from `pkgs.pkgsCross.<target>` and set the matching `CARGO_TARGET_<TRIPLE>_LINKER` and `CC_<triple>` in the devShell.

Minimal skeleton (extend per project; add cross targets and linker env only when needed):

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      perSystem = { pkgs, system, ... }:
        let
          fenix = inputs.fenix.packages.${system};
          rustToolchain = fenix.combine [
            fenix.stable.rustc
            fenix.stable.cargo
            fenix.stable.clippy
            fenix.complete.rustfmt # nightly: unlocks wrap_comments and friends
            fenix.stable.rust-src
            fenix.rust-analyzer
          ];
        in {
          devShells.default = pkgs.mkShell {
            # inputsFrom = [ self'.packages.default ]; # when the flake builds a package
            packages = [ rustToolchain ]; # dev tools on PATH
            nativeBuildInputs = [ pkgs.pkg-config ]; # tools the build invokes
            buildInputs = [ pkgs.openssl ]; # libraries linked against
          };
        };
    };
}
```

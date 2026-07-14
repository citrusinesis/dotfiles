# Rust Service Template

Fenix-managed Rust service template with the conventions used in this repository.

## Included

- Stable Fenix toolchain with `cargo`, `clippy`, `rust-src`, `rustc`, and `rustfmt`
- Company `rustfmt.toml`
- `tokio`, `reqwest` with `rustls`, `serde`, `serde_json`, `dotenvy`, and `thiserror`
- `cargo-deny` bans for `native-tls`, `async-std`, `dotenv`, and direct `hyper` usage
- `nix build` package output and `nix develop` shell

## Commands

```bash
nix develop
cargo fmt
cargo clippy --all-targets --all-features -- -D warnings
cargo deny check
cargo test
nix build
nix run
```

Before the first commit, replace `rust-service` in `flake.nix`, `Cargo.toml`,
and any user-facing strings in `src/`.

If you are building an internal one-off tool instead of a shared service, swapping `thiserror` for
`anyhow` or `eyre` is usually reasonable.

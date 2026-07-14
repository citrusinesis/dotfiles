# Go Service Template

Go service template with a Nix-managed toolchain and a `buildGoModule` package output.

## Included

- `go`, `gopls`, `delve`, `golangci-lint`, and common refactoring helpers in `nix develop`
- `buildGoModule` packaging for `nix build`
- A minimal `cmd/` plus `internal/` layout

## Commands

```bash
nix develop
go test ./...
go test -cover ./...
nix build
```

Before the first commit, replace `go-service` and `example.com/go-service` in
`flake.nix`, `go.mod`, `cmd/`, and the source package imports. When external
modules are added, replace `vendorHash = null;` with the hash suggested by
`nix build`.

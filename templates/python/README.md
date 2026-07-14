# Python Service Template

uv2nix-managed Python service template with the conventions used in this repository.

## Included

- `python3.13` toolchain pinned via Nix flake
- one `uv.lock` dependency graph for development, checks, and the Nix package
- `uv2nix` and `pyproject.nix` for reproducible Python packaging
- `pyproject.toml` with Ruff, BasedPyright, and pytest dev tooling
- `python-dotenv` + `os.getenv("VAR", "default")` for env loading
- `pathlib` everywhere instead of `os.path`
- Stdlib `tomllib` for config loading via `Config.from_path`
- Argument-based override of config values, with the resolved config logged
- `httpx.AsyncClient` for HTTP, no direct `requests`/`urllib`
- `nix build` package output and `nix develop` shell

## Layout

```
.
├── flake.nix
├── pyproject.toml
├── config.toml
├── .env.example
└── src/python_service/
    ├── __init__.py
    ├── __main__.py
    ├── config.py
    ├── errors.py
    └── service.py
```

## Commands

```bash
nix develop
ruff check src tests
ruff format --check src tests
basedpyright
pytest
python-service --config config.toml
nix build
nix run
```

Before the first commit, replace `python-service` and `python_service` in
`flake.nix`, `pyproject.toml`, `src/`, and `tests/`.

The development shell is supplied by Nix from `uv.lock`; do not run `uv sync`
or `uv run` inside it. Use `uv add`, `uv remove`, and `uv lock` only when
changing the dependency graph. `UV_CACHE_DIR` can still point to a shared disk
for those update operations:

```bash
export UV_CACHE_DIR=/path/to/shared/uv-cache
```

If a project depends on a package that has to be built locally, vendor it as a
git submodule under `vendor/` and add it to `pyproject.toml` via
`tool.uv.sources` or a path dependency.

# Python Service Template

uv-managed Python service template with the conventions used in this repository.

## Included

- `python3.12` toolchain pinned via Nix flake
- `uv` for dependency management with `.venv` at project root
- `pyproject.toml` with `black`, `ruff`, `pyright`, and `pytest` dev tooling
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
uv sync
uv run black src tests
uv run ruff check src tests
uv run pyright
uv run pytest
uv run python -m python_service --config config.toml
nix build
```

Set `UV_CACHE_DIR` to a path on the shared disk so the cache is reused across
projects:

```bash
export UV_CACHE_DIR=/path/to/shared/uv-cache
```

If a project depends on a package that has to be built locally, vendor it as a
git submodule under `vendor/` and add it to `pyproject.toml` via
`tool.uv.sources` or a path dependency.

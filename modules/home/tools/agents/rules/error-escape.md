# Rule: Error Escape

A silent error is worse than a loud crash. An error that gets swallowed, encoded into a sentinel, or logged and forgotten turns into a bug that has to be discovered the hard way — usually far from where it was actually caused. Every failure must be explicitly handled, transformed, or propagated upward.

Concretely, do not:

- Swallow errors with bare `except:`, empty `catch` blocks, or `_ = err` style discards.
- Encode failure as a sentinel value — `None`, `-1`, `false`, empty string — when a Result or exception would carry the real shape of the failure.
- Catch a broad exception class just to keep execution moving. Catch the narrowest type you can actually recover from, and let the rest propagate.
- Log or trace inside a failable function and then return as if nothing happened. Logging is not handling.

Errors are part of a function's interface. Design them with the same care as the return type — name the variants, say what each one means, and make them useful to the caller. A function that can fail in five distinct ways but returns one opaque "something went wrong" has thrown away most of the information its caller needed.

Language cues, not language laws:

- In Rust, return `Result` and let `?` carry it. Use `thiserror` for library-style typed errors, `anyhow` or `eyre` for binaries and scripts. Add context at the propagation site with `.context()` or `.wrap_err()` — not by tracing inside the failable function itself.
- In Python, raise exceptions. Don't invent `(value, err)` tuple returns. Catch the narrowest exception you can act on, and never `except: pass`.
- In Go, TypeScript, Gleam, and the like, return the idiomatic error or Result type. Never discard an error return — no `_ = …`, no unawaited Promises, no ignored `Result`.

Reporting belongs at the boundary — the request handler, the CLI entry point, the top-level task. Everything below it should propagate. If you're logging inside a function that can fail, you're probably eating information the caller needed to decide what to do.

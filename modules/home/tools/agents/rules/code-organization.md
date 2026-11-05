# Rule: Code Organization

Organize code by responsibility: one primary abstraction, or one cohesive runtime responsibility, per file — with a clear dependency direction between modules.
The goal is a module tree that explains the architecture from file names alone, without splitting inseparable details into tiny files.

This rule is language-general.
The **Rust specifics** section at the end covers mechanics that only apply to Rust; skip it in other languages.

## Decomposition

- Prefer one primary public type — struct, trait, enum — or one tightly coupled family of types per file.
- Split orchestration by runtime responsibility: planning, scheduling, invocation, scoring, settlement, persistence, reporting.
- Keep a type's inherent behavior beside the type, unless an implementation is itself a distinct subsystem.
- Keep small, related private types together when separating them would hide their relationship rather than clarify it. Do not split by line count.
- Extract a file when its contents are independently understandable, have a distinct dependency set, or can be tested as a coherent unit.
- Avoid catch-all modules — `utils`, `helpers`, `common`, `misc` — unless the contents form a genuine shared abstraction. Name a module after the responsibility it owns.

## Dependency boundaries

- Put stable, consumer-facing contracts and domain types in the core (lowest) layer.
- Put optional implementations and convenience helpers in extension layers, not in core.
- Keep execution, I/O, caching, persistence, and process concerns out of core.
- A facade may re-export domain types but must not define competing wrappers or copies of them.
- Prefer owned values and borrowing. Reach for shared-ownership or reference-counting only for real concurrent sharing or a required owned handle, and make the ownership reason visible in the surrounding design.

## Visibility and API preservation

- Preserve the existing public API during structural refactors, unless an API change was explicitly requested.
- Default new modules and support types to the narrowest visibility that compiles.
- Expose only the intentional consumer-facing surface, and expose it from the nearest parent module.
- Do not widen a type's visibility just to make a file split compile. Move ownership or use internal visibility instead.

## Tests

- Keep focused unit tests beside their implementation.
- Split large integration suites by scenario or responsibility; keep shared fixtures in an explicitly named support module.
- Test intended extensibility from an external integration test when the feature is meant for downstream consumers.

## Refactoring procedure

When reorganizing existing code:

1. Identify the independent abstractions and runtime responsibilities.
2. Define the target module tree and dependency direction before moving code.
3. Move code without changing behavior or public paths.
4. Remove obsolete files.
5. Run the formatter, the linter with warnings denied, the affected tests, then the full suite.

## Rust specifics

- Use the Rust 2018+ module layout exclusively. Module `foo` lives in `foo.rs`; its children live in `foo/*.rs`. Never create `foo/mod.rs`.
- Keep a parent module file small: child `mod` declarations, deliberate re-exports, and only the glue that truly belongs to the module as a whole.
- Default new modules and support types to `pub(crate)` or private, and re-export the intended surface from the nearest parent.
- Put author-facing contracts and domain types in the core crate; keep optional implementations and helpers in extension crates.
- Introduce `Arc` only for real concurrent shared ownership or a required owned async permit, and document the reason through the surrounding type design.
- For the refactoring procedure above, step 5 is `cargo fmt`, then `cargo clippy` with warnings denied, then the affected tests, then the workspace-wide suite. Confirm no `mod.rs` remains.

Example layout:

```text
src/
├── execution.rs
└── execution/
    ├── scheduler.rs
    ├── retry.rs
    └── scoring.rs
```

# Rule: Code Quality

Do not compromise on code quality to get something working faster.
Every piece of code you write should be something you'd be comfortable putting up for review as-is.

Concretely, do not:

- Use loose types where a tighter model fits — enums over stringly-typed values, domain types over primitives where semantics matter.
- Leave a file bloated when it clearly wants to be split — if module boundaries are visible, draw them now.
- Let a function or module accumulate responsibilities. If something is doing more than one thing, split it before it grows further.
- Take a naive implementation path without flagging it. If you're knowingly making a performance or structural tradeoff, say so explicitly and get confirmation.
- Skip error handling, edge cases, or validation on the assumption that someone will add it later.

When you make a non-obvious choice — an algorithmic decision, a structural tradeoff, a subtle invariant — leave a comment explaining why. The code says what; the comment says why you didn't do the more obvious thing instead.

This is not an invitation to over-engineer. Don't introduce abstractions, layers, or patterns that the current requirements don't justify. Clean means fitting — not clever, not maximal.

The bar is not "works." The bar is "a reasonable engineer wouldn't wince reading this."

# Rule: Comments

Default to no comments. Module docs (`//!`) and item docs (`///`) follow the same bar as inline comments: only write one when the *why* is non-obvious.

Prose comments follow `line-breaks.md` in this directory — never wrap mid-sentence for visual width.

Aggressively cut:
- Multi-paragraph module docs narrating architecture. Lead with one sentence on what the file is, stop.
- Doc comments restating what a function name + signature already say.
- Reasoning comments that paraphrase the line they sit above.
- Comments describing what changed from a previous design or implementation. Focus on the current state; otherwise delete.

Keep:
- A one-line module doc when the file's purpose isn't obvious from its name.
- A short comment for behavior that would surprise a reader (workaround, hidden invariant, non-obvious tradeoff).
- `// SAFETY:` blocks where required.

For tests: drop "this verifies that..." preambles. The test name is the doc.

**Never** in comments:
- Hand-drawn separators or section banners (`=====`, `-----`, `──`, `***`, etc.). Code structure shows sections; banners always drift out of sync.
- ASCII art of any kind — boxes, trees, arrows, diagrams. If a picture is genuinely needed, link to a real diagram file.

When in doubt, delete.

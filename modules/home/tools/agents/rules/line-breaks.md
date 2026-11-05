# Rule: Line Breaks

Never insert line breaks in the middle of a sentence or paragraph solely for line length.
In prose, break only at the end of a sentence (once) or end of a paragraph (twice). Remove trailing whitespace at the end of each line.

This applies to all non-code text (commit messages, pull request bodies, documentation, comments, etc.), except that lists, tables, and checklists follow their own structural format.

For source-code comments and doc comments, this means: write sentences and paragraphs as prose, then let the language's formatter (e.g. `cargo fmt`, `prettier`) handle column width. Do not pre-wrap mid-sentence to satisfy a line-length limit.

Do not concatenate multiple sentences into one long sentence to avoid line breaks — that violates the spirit of the rule.
Prefer several short sentences, each on its own line, over one mega-sentence with no breaks.

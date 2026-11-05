---
allowed-tools: Bash(git status), Bash(git diff), Bash(git log), Bash(git add), Bash(git commit), Bash(git branch), Read
description: Prepare and commit changes to GitHub
argument-hint: [commit message (optional)]
---

# Git Commit

Execute the steps below in order.

## 1. Quality Control (Lint, Format, Test & Doc)

- Check for project files and run the standard quality tools:
  - Go: `go fmt ./...`, `golangci-lint run --fix`, `go test ./...`
  - Nix: `alejandra .`
  - Rust: 
    - `cargo fmt`
    - `cargo clippy --all-targets --fix --allow-dirty` (Must pass `--all-targets` for test-module lints)
    - `cargo test` or `cargo nextest` (Run unit/integration tests if applicable)
    - `RUSTDOCFLAGS="-D warnings" cargo doc --no-deps` (Verify documentation builds without broken links or errors)
    - *Note: For new/standalone example crates, run these tools from inside the example directory.*
  - Python: `ruff format`, `ruff check --fix`, `pytest` (if configured)
  - Gleam: `gleam format`, `gleam test`
- Documentation & Testing (Optional/Conditional):
  - If the project includes a documentation suite or automated tests, ensuring they pass/build is part of the "Quality Control" phase.
  - For `feat` or `fix` commits, always verify that documentation builds correctly if changes affect the public API.
- WIP Logic:
  - If `$ARGUMENTS` starts with `wip`, you are permitted to skip linting, formatting, testing, and doc-checks for speed.
  - For all other types (`feat`, `fix`, etc.), these checks are MANDATORY.
- Do NOT bypass pre-commit hooks (using `--no-verify`) for standard commits, if configured. Bypassing is only allowed for `wip` commits if the user explicitly confirms the need for a quick save despite failures.

## 2. Inspect current state

```
git status
git diff
git log --oneline -5
git branch --show-current
```

## 3. Analyse changes

- Review staged / unstaged / untracked files.
- Determine the nature of the changes from the diff (feat / fix / refactor / test / docs / chore / etc.).
- Warn the user and exclude from staging any files that must not be committed (`.env`, secrets, large binaries).

## 4. Update project foundation files (mandatory)

Before committing, **always** update the files below to reflect the current work — only if they need it:

- `README.md`, `docs/**/*.md` — reflect any changes to the public API, installation steps, or usage examples.
- `.gitignore` — add new artifact types if not already covered.

Leave files that need no changes untouched. Include any updated files in staging.

## 5. Commit message rules

- Write in **English**.
- Conventional Commits format: `<type>(<scope>): <subject>` (lowercase)
  - Allowed types: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`, `style`, `perf`, `wip`, `etc`
  - `<scope>` is the category to which the changes apply; it should be written as a single lowercase English word and can be omitted (e.g. api, cli, ci, docs)
  - If there are changes that break backward compatibility, highlight them by adding an exclamation mark (!) before the clone, as in `feat(api)!: <subject>`
- Keep the subject under 50 characters, imperative mood (e.g. "add", "fix", "update" — not "added", "fixed").
- Add a body after a blank line if more detail is needed.
- Body lines (and bullet items) must obey `~/.claude/rules/line-breaks.md`: never break mid-sentence for visual width — break only at end of sentence or end of paragraph. Long lines are correct; soft-wrapped paragraphs are wrong.
- Use `$ARGUMENTS` as a hint for the commit message if provided.
- Don't mention about 'co-author claude'

## 6. Stage files

- Selectively `git add` only the relevant files, excluding any sensitive ones.

## 7. Commit

- Show the final commit message to the user and get confirmation.
  - Confirmation is MANDATORY. Wait for approval regardless of the running mode, previous context, etc.
- After approval, commit it using a HEREDOC for the message.

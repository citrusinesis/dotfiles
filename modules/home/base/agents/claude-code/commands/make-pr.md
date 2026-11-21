---
allowed-tools: Bash(git status), Bash(git diff), Bash(git log), Bash(git branch), Bash(git push), Bash(gh pr create), Bash(gh pr list)
description: Draft and create a pull request
argument-hint: [base branch (optional, infer if not provided, main if not inferrable)]
---

# Create Pull Request

Create a PR from the current branch without touching staged files or commits.

## 1. Check current state

```sh
git branch --show-current
git status
git log --oneline -10
```

## 2. Determine base branch

- If `$ARGUMENTS` is provided, use it as the base branch.
- Otherwise:
  - Try to infer from the session context.
  - If you can't infer, think of it as `main`.
  - If the branch is not provided (regardless of whether it is inferred or not), get the user to confirm the base branch and proceed further.
- If the current branch equals the base branch, abort and notify the user.

## 3. Analyze changes

- Run `git log <base>..HEAD --oneline` to list commits to be included.
- Run `git diff <base>...HEAD` to understand what changed.
- Identify the nature of changes and key content.

## 4. Write PR title and body

**Title rules:**
- If a single dominant commit exists, use its message verbatim.
- Otherwise:
  - Under 50 characters, English, imperative mood.
  - Conventional Commits format: `<type>(<scope>): <subject>` (lowercase)
    - Allowed types: `feat`, `fix`, `refactor`, `chore`, `test`, `docs`, `style`, `perf`, `wip`, `etc`
    - Use `!` for breaking changes: `feat(api)!: <subject>`.

**Body rules (English only):**

All body text (including bullet items) must obey `~/.claude/rules/line-breaks.md`: never break mid-sentence for visual width — break only at end of sentence or end of paragraph.
Long lines are correct; soft-wrapped paragraphs are wrong.

1. Verbatim Mode: If a single dominant commit exists and has a body description, use that description verbatim.
2. Simplified Mode: If the changes are focused on a single logic/context or aren't complex enough to need categorization (even if they involve several files), skip the headers and just provide a concise list of bullet points.
3. Standard Mode: For large-scale changes or multiple distinct updates, use the template:

```markdown
## Summary

- 2-3 bullet points summarizing the key changes

## Details

- Nested bullet points listing technical changes and logic updates
```

## 5. Sync remote branch

- If the current branch has no remote tracking branch, run `git push -u origin <branch>` first.
- If it already exists remotely, skip the push.

## 6. Create PR

- Run `gh pr list --head <current>` to check for an already-open PR on this branch. If one exists, notify the user and abort.
- Show the final PR draft to the user and get confirmation.
  - Confirmation is MANDATORY. Wait for approval regardless of the running mode, previous context, etc.
- After approval, run `gh pr create --base <base>` using a HEREDOC for the body and print the PR URL for the user.
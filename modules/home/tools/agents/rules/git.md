# Rule: Git

IMPORTANT: Never commit on your own initiative. A commit is allowed only:
- during `/implement`, whose workflow commits each task as it lands,
- during `/commit`, or
- when the user explicitly asks for a commit.

Outside these, never run `git commit` — no exception.

IMPORTANT: Never push on your own initiative. A push is allowed only:
- during `/make-pr`, which the user invokes to open a pull request, or
- when the user explicitly asks to push.

No command or workflow may push automatically — `/implement` commits but never pushes. Outside these two cases, never run `git push` — no exception.

## Signing

Commits are GPG-signed, and a pinentry prompt takes over the terminal and breaks the agent's TUI.
Every git command that may create a signature — `commit`, `merge`, `rebase`, `cherry-pick`, `revert`, `tag` — runs with `git -c gpg.program=gpg-nopinentry …`, so an uncached passphrase fails at once with `No pinentry` instead of prompting.

When signing fails that way:
- Stop and ask the user to unlock the key in a separate terminal with `echo | gpg --clearsign >/dev/null`, then wait for their reply.
- Retry the same command once they confirm.
- Never disable signing (`--no-gpg-sign`, `-c commit.gpgsign=false`) and never run the command without the wrapper to get past the failure.

Agents running non-interactively for an orchestrator report the signing failure and stop instead of waiting; the orchestrator asks the user.

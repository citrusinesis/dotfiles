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

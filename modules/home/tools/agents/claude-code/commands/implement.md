---
description: Implement an approved spec by orchestrating Codex or Claude agents, then review the result
argument-hint: <path to spec file> [--agent codex|claude]
allowed-tools: Bash, Read, Write, Agent, mcp__paseo
---

# Implement

Implement a spec by orchestrating Codex or Claude agents, then review the result.

Default agent is Codex; if Codex isn't ready, it automatically falls back to Claude and says so. Pass `--agent claude` to force Claude, or `--agent codex` to require Codex with no fallback.

Agents run through one of two executors, picked in step 1:
- **Paseo**: the session has the Paseo tools (`mcp__paseo__*`), which it does when Paseo launched it. Agents run as Paseo agents and show up in the Paseo apps.
- **Direct**: anywhere else. Agents run as `codex exec` processes or Claude subagents.

Everything outside step 2 is shared by both executors.

## Dispatch Strategy

You are the orchestrator — read the spec, decide how to split and assign work, coordinate the agents, handle merges, and review the result.

The agents are your hands. How you organize the work is entirely your call.

Some examples of valid approaches:
- Run everything sequentially in one agent session
- Fan out every task into its own worktree and run in parallel
- Group tasks 3+4 together because they touch the same module, run the rest independently
- Run T1 first to unblock T2–T5, then fan those out in parallel

There is no checklist. Read the shape of the tasks and do what makes sense. State your plan briefly before executing.

## Task Prompt

Give every agent this prompt, whichever executor runs it:

```
Read <spec-path> and implement <specific task(s)> only.

You are running non-interactively for an orchestrator. Do not ask questions or wait for confirmation; if the task is blocked or ambiguous, stop and report why. Never push.

1. Implement the change
2. Run the L1 verification command from the spec
3. If it passes, commit: use a short conventional commit message
4. Check off the task in the spec file and commit that too

Report any skipped steps and why.
```

## Workflow

### 1. Parse arguments and pick the executor

Extract the spec file path and optional `--agent` flag from `$ARGUMENTS`.

Read the spec file. Confirm it exists and has at least one unchecked task.

Pick the executor: Paseo if the `mcp__paseo__*` tools are available in this session, otherwise Direct. State which one you picked.

Apply the dispatch strategy above and decide: sequential, fan-out, or grouped.
For fan-out or grouped work, name each branch `implement/<spec-slug>-<task-id>`, where `<spec-slug>` is the spec file name without its date and extension.

### 2. Run the agents

Follow only the section for the executor picked in step 1.

#### Paseo executor

Pick the provider:
- Call `list_providers`. Use `codex` if it is available; otherwise fall back to `claude` and report the fallback. `--agent codex` requires `codex` with no fallback; `--agent claude` uses `claude`.
- Call `list_models` for that provider and use its default model.

For fan-out or grouped work, create a worktree workspace per task (or group) with `create_workspace`:
- `isolation: "worktree"`, `mode: "branch-off"`, `branchName: "implement/<spec-slug>-<task-id>"`.
- `baseBranch`: the current local branch. Paseo otherwise bases new worktrees on the upstream, which lacks unpushed commits such as the spec itself.

Start each agent with `create_agent`:
- `provider: "<provider>/<model>"`, `title: "<task-id>: <short summary>"`, `initialPrompt`: the task prompt above.
- `workspaceId`: the task's workspace; omit it for sequential work so the agent runs in your own workspace.
- `settings.modeId`: `auto-review` for Codex (keeps the workspace-write sandbox) or `auto` for Claude (classifier-reviewed permissions).

Wait for the finish notifications instead of polling.
When an agent needs permission, inspect it with `list_pending_permissions`: approve requests that stay within its task with `respond_to_permission`, deny the rest and report them.
When an agent errors, report it and leave the other agents running.

#### Direct executor

Unless `--agent claude` was passed, run the readiness check from the Codex Execution rule (`/codex:setup`) once.
If Codex isn't ready and `--agent codex` wasn't forced, run Claude subagents instead and report the fallback.
A *sandbox* failure is not a fallback trigger — Codex still runs unsandboxed per the rule; only an unready Codex (missing or unauthenticated) routes to Claude.

For fan-out or grouped work, create a worktree per task (or group) on its own branch:

```bash
git worktree add -b implement/<spec-slug>-<task-id> .worktrees/<task-id> HEAD
```

With Codex, invoke it in each worktree (or the project root if sequential) per the Codex Execution rule (probe the sandbox, pick the mode) with the task prompt.
Run all sessions as background bash commands in parallel and wait for all to complete.

With Claude, spawn a subagent per task (or group) via the Agent tool, with `Working directory: .worktrees/<task-id>` (or the project root if sequential) followed by the task prompt.

### 3. Merge branches (if parallel)

After all agents complete, merge each task branch back into the current branch:

```bash
git merge implement/<spec-slug>-<task-id>
```

Resolve any merge conflicts directly — don't stop to ask the user.

Then remove each worktree: `archive_workspace` for the Paseo executor, `git worktree remove .worktrees/<task-id>` for the Direct executor.

### 4. Review the diff

Run:

```bash
git log --oneline -10
git diff HEAD~<n>  # n = number of commits made
```

Review the diff and report:
- Which executor and provider ran the tasks, and any fallback
- What was implemented
- Any issues found (bugs, missing tests, style problems, anything unexpected)
- Severity: critical / should-fix / minor / looks good
- Any merge conflicts that were resolved and how

Keep the review concise.
Don't auto-fix — the user decides what to do next.

## Notes

- If an agent fails to start or exits with an error, report it clearly
- If the spec has no unchecked tasks, say so and stop
- Remove worktrees even on failure: Paseo workspaces with `archive_workspace`, `.worktrees/` with `git worktree remove`
- For how to invoke Codex directly (sandbox probe, mode selection, `codex:rescue` vs direct `codex exec`), follow the Codex Execution rule

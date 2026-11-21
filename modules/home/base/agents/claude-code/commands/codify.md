---
description: Codify session observations into minimal, generalizable settings updates (postmortems, new commands, new rules)
argument-hint: [optional: scope hint, e.g. "the commit issues", "a release-prep flow"]
---

# Codify

Turn observations from the current session into **durable settings-level changes**: a postmortem on mistakes, a new slash command for a recurring workflow, or a new global rule.

The bar is: a future Claude with no memory of this conversation should still benefit from the change.

## 1. Identify the trigger

Pick the mode that matches `$ARGUMENTS` (or, if absent, scan the session and pick the dominant one):

- **Postmortem** — the user had to flag or correct a mistake. Goal: prevent the *class* of mistake.
- **New command** — a multi-step workflow recurred this session and would recur again. Goal: codify it as a slash command.
- **New rule** — a principle came up across unrelated contexts. Goal: capture it as a global rule.

Skip one-off judgment calls with no generalizable lesson.

## 2. Capture the observation

For each item, write down:

- **What happened** — one sentence, factual.
- **Why it matters** — the root cause (postmortem) or the recurring pattern (new command/rule).
- **Class** — the general failure mode or workflow shape, *not* the specific incident.

## 3. Choose the right durability layer

Pick the **lowest-friction durable layer** that addresses the class:

| Layer | When to use |
|---|---|
| Edit a slash command in `~/.claude/commands/*.md` | The behavior belongs inside an existing command's workflow (e.g. `/commit`, `/make-pr`). Add a single line that loads in-context every invocation. |
| Add a new slash command in `~/.claude/commands/*.md` | A multi-step workflow recurs and is worth invoking by name. Keep it short — only the steps that aren't obvious. |
| Edit `~/.claude/rules/*.md` (or add a new one) | The rule applies broadly across all work, not tied to a specific command. |
| Add a hook in `settings.json` | The behavior must be enforced by the harness (e.g. blocking a tool call, running on Stop). Use the `update-config` skill. |
| Save a memory under `memory/` | **Last resort.** Only for project-specific or behavioral nuance the above layers can't capture. |

Rules of thumb:

- **Don't duplicate.** If a rule already exists, *reference* it from the relevant slash command rather than restating its content.
- **Don't over-encode.** A one-line note in the right place beats a paragraph somewhere generic.
- **Generalize.** "Run clippy with `--all-targets`" is right; "remember the exa_search test-module warning" is wrong.
- **Prefer single-line edits.** If a change needs more than ~3 lines, justify why a smaller edit can't carry the rule.

## 4. Draft the edits

For each chosen edit, show the user:

- **File** being changed (or created).
- **Diff** — ideally one line. New commands stay terse: only the non-obvious steps.
- **Why this layer** — one sentence on why this is the right place vs. alternatives.

## 5. Confirm before applying

Show all proposed edits in one batch.
Wait for approval.
Confirmation is MANDATORY regardless of running mode.

## 6. Apply and clean up

After approval:

- Apply the edits.
- Remove any now-redundant memory entries that the new settings supersede (and update `MEMORY.md`).
- Briefly summarize what changed and where the rules now live.

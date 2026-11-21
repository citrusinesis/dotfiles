---
description: Create a spec document for a goal
argument-hint: <goal or description>
allowed-tools: Bash, Read, Write, Glob, Grep
---

# Spec

Create a spec document that `/implement` can execute.

## Workflow

### 1. Understand the goal

Read `$ARGUMENTS` as the goal. If it references a file, read it.

Explore the codebase briefly — understand the structure, existing tests, and relevant files.

### 2. Write the plan

Save to `docs/specs/<timestamp>-<short-slug>.md` where:
- `<timestamp>` is the current date as `YYYYMMDD`
- `<short-slug>` is 2–4 words from the goal, hyphenated

### Plan format

```markdown
# <goal>

## Tasks
- [ ] T1: <description>
  - Files: `src/foo.ts`
  - Context: <any gotchas or relevant info, keep brief>
- [ ] T2: <description>
  - Files: `src/bar.ts`
  - Depends on: T1

## Verification
- L1 (each task): `<fast test command>`
- L3 (final): `<full test command>`

## Rules
- <any project-specific constraints worth noting>
```

### 3. Present the plan

Show the spec path and content.
Tell the user to review and edit it, then run `/implement <path>` when ready.

## Notes

- Keep task descriptions concrete and unambiguous
- Files field is a starting hint, not a hard restriction
- Rules should only be things not already obvious from the codebase
- Don't start implementing — this command only produces the plan

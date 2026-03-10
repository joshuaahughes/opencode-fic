# Project Agent Configuration

## What
[Replace with a 2-sentence description of your project and its purpose.]

## Stack
[Replace with your key technologies, e.g. TypeScript, Go, React, Postgres, etc.]

## How to verify changes
```
# Replace with your test/build commands
npm test
npm run typecheck
npm run build
```

## Workflow: FIC (Frequent Intentional Compaction)

For any non-trivial task (touches more than 1-2 files), use the FIC workflow:

1. `/research $ISSUE_OR_TASK` — explore first, write nothing
2. `/plan thoughts/research/[output].md` — plan from the research doc, not from memory  
3. `/implement thoughts/plans/[output].md` — execute phase by phase

Before starting a multi-file task, load the workflow skill:
> "Load the fic-workflow skill before we begin."

**Never exceed 60% context in any session. Start a new session at every phase boundary.**

## Agent Docs
Only read these when relevant to your current task:

- `agent_docs/architecture.md` — system structure and component relationships
- `agent_docs/testing.md` — how to run, write, and interpret tests
- `agent_docs/conventions.md` — code style, patterns, and naming conventions
- `agent_docs/database.md` — schema, migrations, and query patterns (if applicable)
- `agent_docs/deployment.md` — build, release, and deploy process (if applicable)

## Hard Rules
- Do not modify `AGENTS.md` or files in `.opencode/` without explicit instruction
- Do not install new dependencies without asking
- Prefer reading existing code patterns over inventing new ones
- If reality diverges from the plan, surface it immediately — do not improvise silently

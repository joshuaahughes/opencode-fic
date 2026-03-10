---
description: "FIC Phase 3 — Implement a plan phase by phase. Runs isolated. Usage: /implement thoughts/plans/[plan-doc].md [optional: 'phase N only']"
agent: build
---
You are in FIC Phase 3: Implementation.

Plan document: $ARGUMENTS

## Your Instructions

Read the plan document at the path above. Implement it phase by phase.

## Process

1. Read the plan doc fully
2. Confirm your understanding of Phase 1 with the user before starting
3. Implement Phase 1 steps in order
4. After each phase:
   - Run the automated verification command from the plan
   - Check off completed steps (update the plan doc checkboxes)
   - Report results clearly
   - List the manual verification steps for the user to perform
   - WAIT for user confirmation before proceeding to the next phase
5. Maintain `thoughts/progress/[topic]-progress.md` for complex multi-session tasks

## Progress Tracking

If this task spans multiple sessions, maintain a progress doc at
`thoughts/progress/[topic]-progress.md`:

```
## Goal
## Completed Steps
  - [✓] Phase 1, Step 1 — [brief note]
## Current Step
  - [→] Phase 1, Step 2
## Remaining Steps  
  - [ ] Phase 2, Step 1
## Divergences from Plan
  - [any surprises — record here, do not silently work around them]
```

## Hard Rules
- Execute steps in the order specified in the plan
- Run tests after each phase — never skip verification
- If reality diverges from the plan: STOP, document the divergence in the
  progress doc, and surface it to the user before continuing
- Do NOT refactor things not in the plan
- Do NOT install dependencies not in the plan
- Update plan checkboxes as you complete steps
- If resuming a session, read the progress doc first and confirm current state
  with the user before doing anything

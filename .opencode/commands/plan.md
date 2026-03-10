---
description: "FIC Phase 2 — Create implementation plan from a research doc. Runs isolated. Usage: /plan thoughts/research/[research-doc].md"
subtask: true
agent: planner
---
You are in FIC Phase 2: Planning.

Research document: $ARGUMENTS

## Your Instructions

Read the research document at the path above. Then create a precise,
phased implementation plan.

## Process

1. Read the research doc fully
2. Identify any gaps or ambiguities — list them as open questions
3. Share your open questions AND a rough phase outline with the user BEFORE writing the plan
4. Incorporate feedback, then write the final plan doc

Work back and forth with me, sharing your open questions and phases outline
before writing the plan.

## Output Format

Write the plan to `thoughts/plans/` using filename format:
`YYYY-MM-DD_[short-topic-slug]-plan.md`

Structure the plan doc as:
```
## Goal
[1 sentence: what does success look like]

## Context
Research doc: [path to research doc]
Started: [date]

## Phases

### Phase 1: [Descriptive Name]
- [ ] Step 1 — File: `src/foo.ts`, Function: `handleX()`, Change: [precise description]
- [ ] Step 2 — File: `src/bar.ts`, Add: [precise description]
- Automated verification: `npm test src/foo.test.ts`
- Manual verification: [what to check by hand]

### Phase 2: [Descriptive Name]
- [ ] Step 1 — ...
- Automated verification: ...
- Manual verification: ...

## Risks and Open Questions
[Anything that could go wrong or needs human decision]

## Out of Scope
[Explicitly list what this plan does NOT cover]

## Progress
[Leave blank — filled in during implementation]
```

## Hard Rules
- Do NOT write any code
- Do NOT make file edits
- Each step must reference exact files and functions
- Every phase must include both automated and manual verification steps
- When done, tell the user the path to the plan doc and ask them to review and approve it before proceeding to /implement

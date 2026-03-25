---
name: fic-workflow
description: Frequent Intentional Compaction - the research/plan/implement context engineering workflow for tackling hard problems in complex codebases
---

# Frequent Intentional Compaction (FIC) Workflow

## Core Principle

LLMs are stateless functions. Output quality = context quality. The FIC workflow
structures work into discrete phases with explicit compaction boundaries so every
phase starts with a clean, correctly-scoped context window.

**Error compounding:**
- Bad research → thousands of bad lines of code
- Bad plan → hundreds of bad lines of code  
- Bad code → one bad line of code

This means the highest-leverage review point is the research doc and plan —
not the code.

---

## The Three Phases

### Phase 1: Research
**Goal:** Understand the codebase. Do NOT suggest fixes.

- Use subagents (via `@explore` or Task tool) for all file searches and reads
- Subagents run in isolated contexts — their noise stays out of your context
- Target context utilization: 30-40% for this phase
- Output: `thoughts/research/YYYY-MM-DD_[topic]-research.md`

**Research doc structure (~200 lines max):**
```
## Problem Summary
## Relevant Files (with exact line numbers)
## Information Flow (e.g. parse() → validate() → execute())
## Key Findings
## Open Questions
## Recommended Approach (1 paragraph only)
```

**Magic words to end every research prompt:**
> "Do not make an implementation plan or explain how to fix."

---

### Phase 2: Plan
**Goal:** Define precise steps. Do NOT write code.

- Start a FRESH session with only the research doc as context
- Work interactively: share open questions and phase outline BEFORE writing the plan
- Target context utilization: 30-50% for this phase
- Output: `thoughts/plans/YYYY-MM-DD_[topic]-plan.md`

**Plan doc structure (~200 lines max):**
```
## Goal
## Phases
  ### Phase 1: [Name]
  - [ ] Step 1: File: X, Function: Y, Change: Z
  - [ ] Step 2: ...
  - Automated verification: `npm test src/foo.test.ts`
  - Manual verification: [what to check by hand]
  ### Phase 2: [Name]
  ...
## Risks and Open Questions
## Out of Scope
```

**Magic words to end every planning prompt:**
> "Work back and forth with me, sharing your open questions and phases outline
> before writing the plan."

---

### Phase 3: Implement
**Goal:** Execute the plan. Track progress. Pause at phase boundaries.

- Start a FRESH session with only the plan doc as context
- Execute steps in order, check off boxes as you go
- Run verification after each phase before proceeding
- For long tasks, maintain `thoughts/progress/[topic]-progress.md`
- If reality diverges from the plan: STOP and surface it — do not improvise

**Progress doc structure:**
```
## Goal
## Completed Steps
  - [✓] Phase 1, Step 1 — brief note on what was done
## Current Step
  - [→] Phase 1, Step 2
## Remaining Steps
  - [ ] Phase 2, Step 1
## Divergences from Plan
  - [any surprises or deviations]
```

---

## Context Management Rules

| Rule | Detail |
|------|--------|
| Max context per session | 60% — start fresh before hitting this |
| Phase transitions | Always start a new session |
| State storage | Markdown files in `thoughts/`, not conversation history |
| Subagent use | Use `@explore` for all file reads during research |
| Plan mutations | Update the plan doc in place — it's the source of truth |

---

## Subagent Context Isolation

When doing research, delegate file operations to subagents:
```
@explore Find all files that handle authentication. 
Return only: file paths, relevant line ranges, and a 3-sentence summary.
Do not return raw file contents.
```

This keeps your primary context clean. The subagent's grep/read noise stays
in its own context window.

---

## Thoughts Directory Structure

```
thoughts/
  research/
    2025-01-15_auth-bug-research.md
    2025-01-16_payment-flow-research.md
  plans/
    2025-01-15_auth-bug-plan.md
    2025-01-16_payment-flow-plan.md
  progress/
    2025-01-15_auth-bug-progress.md
```

Keep `thoughts/` outside your git repo (symlinked in or a sibling directory)
so research artifacts don't pollute your history.

---

## Human Review Checkpoints

1. **Review research doc** before creating plan — is the codebase understanding correct?
2. **Review plan** before implementing — is the approach sound?
3. **Optional code review** — lowest leverage but still valuable

Reviewing ~400 lines of specs gives more value than reviewing 2000 lines of generated code.

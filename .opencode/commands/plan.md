---
description: "FIC Phase 2 — Create or continue an implementation plan. Usage: /plan thoughts/research/[research-doc].md OR /plan thoughts/plans/[existing-plan].md"
subtask: true
agent: planner
---
You are in FIC Phase 2: Planning.

Argument: $ARGUMENTS

## Step 1: Detect mode

First, determine what was passed in `$ARGUMENTS`:

### Case A — A research doc was passed (path contains `/research/`)
Derive the plan doc path:
- Extract the slug from the research filename (strip date prefix and `-research` suffix)
- Plan path = `thoughts/plans/YYYY-MM-DD_[slug]-plan.md` (use today's date and relevant key terms)
- Check if that plan file already exists with `ls thoughts/plans/`

  **If plan file does NOT exist yet → go to Step 2 (Create Draft)**
  **If plan file already exists → go to Step 3 (Continue Draft)**

### Case B — A plan doc was passed directly (path contains `/plans/`)
The plan file already exists. Go to Step 3 (Continue Draft).

---

## Step 2: Create Draft (first run)

The plan file does not exist yet. Do this immediately — do not ask questions first:

1. Read the research doc at `$ARGUMENTS`
2. Write a draft plan file to `thoughts/plans/` right now with this structure:

```markdown
# Plan: [topic]

## Status: DRAFT — needs review
## Research doc: $ARGUMENTS
## Started: [today's date]

## Goal
[1 sentence from the research doc's recommended approach]

## Open Questions
> These must be answered before this plan is finalised.
> Answer them by editing this section, then re-run /plan on this file.

- [ ] Q1: [first thing you need clarified]
- [ ] Q2: [second thing you need clarified]

## Phase Outline (draft)
> Rough shape only — steps will be filled in once open questions are answered.

### Phase 1: [Name] — [1-sentence goal]
### Phase 2: [Name] — [1-sentence goal]

## Phases (to be filled in)
[empty until open questions are resolved]

## Risks
[anything that could go wrong]

## Out of Scope
[explicit exclusions]
```

3. After writing the file, tell the user:
   - The path to the draft plan file
   - The open questions that need answers
   - How to continue: "Answer the questions by editing the plan file directly, then run `/plan thoughts/plans/[filename].md` to continue."

**Stop here. Do not ask questions in chat. The file is now the conversation.**

---

## Step 3: Continue Draft (subsequent runs)

The plan file exists. Read it now.

Check the `## Open Questions` section:

### If open questions remain (any `- [ ]` items):
- Read all unanswered questions
- Check if any answers were added to the file since last run (look for text after the question)
- For any questions that now have answers: acknowledge them and mark as `- [x]`
- For any still-unanswered questions: remind the user what's needed
- If ALL questions are answered: proceed to finalise the plan (below)
- If questions remain: tell the user what's still needed and stop

### If all open questions are answered (all `- [x]` or section is empty):
Finalise the plan:
1. Read the research doc again for reference
2. Fill in the `## Phases` section with precise steps:
   - Each step: `File: path/to/file.ts, Function: name(), Change: [exact description]`
   - Each phase: automated verification command + manual verification checklist
3. Update `## Status` to `READY FOR REVIEW`
4. Save the file
5. Tell the user the plan is ready and ask them to review before running `/implement`

---

## Hard Rules
- NEVER write code
- NEVER edit source files (only write to `thoughts/plans/`)
- The plan file is the source of truth — all state lives there, not in chat
- If uncertain about anything, add it as an open question in the file
- Precise steps beat vague steps: "modify `refreshToken()` at line 45 to add retry logic" not "update auth"
# Architecture

> Replace this file with your actual architecture notes.
> Keep it under 150 lines. Use file:line references, not code snippets.
> This file is loaded on-demand — write it for an AI that knows nothing about your project.

## Overview
[1 paragraph: what the system does and its primary components]

## Component Map
```
[top-level directory tree with 1-line descriptions]
src/
  api/        — HTTP handlers and routing
  services/   — business logic
  db/         — database models and queries
  utils/      — shared utilities
```

## Key Entry Points
- `src/main.ts:1` — application bootstrap
- `src/api/router.ts:1` — all route definitions
- [add your own]

## Data Flow
[Trace the path of a typical request through the system]
e.g. HTTP request → router → middleware → handler → service → db → response

## External Dependencies
[Key third-party services, APIs, or infrastructure this system talks to]

## Known Complexity / Gotchas
[Anything surprising or non-obvious about the codebase that trips people up]

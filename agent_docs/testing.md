# Testing

> Replace this file with your actual testing notes.
> This file is loaded on-demand by agents working on test-related tasks.

## Running Tests
```bash
# All tests
[your test command]

# Single file
[your test command] src/foo.test.ts

# Watch mode
[your watch command]

# With coverage
[your coverage command]
```

## Test Structure
[Where tests live and how they're organized]
```
src/
  foo.ts
  foo.test.ts     — unit tests co-located with source
tests/
  integration/    — integration tests
  e2e/            — end-to-end tests
```

## Writing Tests
[Key patterns and conventions used in this codebase]
- Framework: [jest / vitest / go test / pytest / etc.]
- Mocking approach: [how you mock dependencies]
- Fixtures: [where test data lives]
- Example of a typical test: `src/[example].test.ts:[line]`

## Test Verification After Changes
After any code change, always run:
```bash
[specific commands for smoke testing your changes]
```

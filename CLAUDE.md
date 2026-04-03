# MTBox Campaign Tracker

## Product
A Flutter mobile app that lets users create, track, and complete personal habit and goal campaigns (e.g., "exercise 30 days", "read 10 books").

## Tech Stack
- Flutter (latest stable, v3.41.4)
- Dart
- State management: Riverpod
- Local storage: Hive
- Navigation: go_router

## How to Run
```bash
export PATH="/Volumes/ex-ssd/flutter/bin:$PATH"
flutter pub get
flutter run
```

## How to Run Tests
```bash
export PATH="/Volumes/ex-ssd/flutter/bin:$PATH"

# Unit + widget tests
flutter test test/

# E2E integration tests (requires iOS Simulator running)
open -a Simulator
flutter test integration_test/
```

## Agent Roles
- **PM**: Breaks down issues, writes acceptance criteria, routes workflow in Linear
- **Designer**: Creates HTML mockups in mockups/<issue-id>/, screenshots them with Playwright
- **Programmer**: Implements features in lib/, opens PRs on GitHub
- **QA**: Writes and runs tests in test/ and integration_test/

## Repository Layout
- `lib/` — Flutter app source code
- `mockups/` — HTML mockups per issue (mockups/<issue-id>/index.html + mockup.png)
- `test/` — Unit and widget tests
- `integration_test/` — E2E tests
- `docs/AGENTS.md` — Shared conventions for all agents
- `docs/memory/` — Per-agent persistent memory

## Linear
- Workspace: MTBox
- Project: Campaign Tracker App (ID: d7b5fab6-e39b-4933-bbab-1ee32c360d83)
- Team ID: 86ce1fdb-7a21-4eb3-a9cc-b0504f3363ad
- Workflow: Backlog → In Design → Awaiting Design Approval → In Progress → In Review → Awaiting Decision → Done
- CEO: levulinhkr (ID: adcd822a-946e-4d74-9c0b-1f55e274706b)

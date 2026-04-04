# MTBox — Campaign Tracker

A Flutter mobile app for creating, tracking, and completing personal habit and goal campaigns (e.g., "exercise 30 days", "read 10 books").

## Tech Stack

- **Flutter** (v3.41.4)
- **Dart**
- **Riverpod** — state management
- **Hive** — local storage
- **go_router** — navigation

## Getting Started

```bash
export PATH="/Volumes/ex-ssd/flutter/bin:$PATH"
flutter pub get
flutter run
```

## Running Tests

```bash
export PATH="/Volumes/ex-ssd/flutter/bin:$PATH"

# Unit + widget tests (no device needed)
flutter test test/

# E2E integration tests (requires physical Android device via USB)
flutter devices  # verify device is detected
flutter test integration_test/ -d android
```

## Project Structure

```
lib/                  # Flutter app source code
mockups/              # HTML mockups per issue (mockups/<issue-id>/index.html + mockup.png)
test/                 # Unit and widget tests
integration_test/     # E2E tests
docs/AGENTS.md        # Shared conventions for all agents
docs/memory/          # Per-agent persistent memory
```

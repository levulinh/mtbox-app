# MTBox Agent Shared Context

This file is maintained by the PM agent and read by all agents each run.
It records cross-cutting decisions that all agents must follow.

## Linear Identifiers
- Team ID: 86ce1fdb-7a21-4eb3-a9cc-b0504f3363ad
- Project ID: d7b5fab6-e39b-4933-bbab-1ee32c360d83
- CEO user ID: adcd822a-946e-4d74-9c0b-1f55e274706b
- CEO username: levulinhkr
- Project name: Campaign Tracker App

## GitHub
- Repo: https://github.com/levulinh/mtbox-app
- Local clone: /Volumes/ex-ssd/workspace/mtbox-app
- Default branch: main
- Branch naming: feat/<linear-issue-id>-<short-description>

## Flutter
- SDK path: /Volumes/ex-ssd/flutter/bin
- Always prefix flutter commands: export PATH="/Volumes/ex-ssd/flutter/bin:$PATH"

## Agent Comment Prefixes (always use these exactly)
- PM: [PM]
- Designer: [Designer]
- Programmer: [Programmer]
- QA: [QA]

## Workflow Statuses (exact names as in Linear)
- Backlog
- In Design
- Awaiting Design Approval
- In Progress
- In Review
- Awaiting Decision
- Done

## Architecture Decisions
(PM agent appends here as decisions are made)

## Style Decisions
(Designer agent appends here as design system evolves)

## Known Issues / Things to Avoid
- The external SSD (/Volumes/ex-ssd) may produce macOS ._* resource fork files. Run `find .git -name "._*" -delete` if git complains about non-monotonic index.
- Android Emulator AVD "MTBox_QA" is configured at ~/.android/avd/MTBox_QA.avd (internal APFS — required because ExFAT on the SSD does not support hard links used by the emulator's file locking)
- Android SDK is at /Volumes/ex-ssd/android-sdk (SDK binaries work fine on ExFAT; only the AVD runtime data must be on APFS)
- QA agent starts/stops the emulator autonomously — no device needs to be connected
- If emulator fails to start, QA agent will skip E2E and note it in the Linear comment
- When iOS Simulator is needed: symlink CoreSimulator to SSD first: `sudo mv ~/Library/Developer/CoreSimulator /Volumes/ex-ssd/CoreSimulator && ln -s /Volumes/ex-ssd/CoreSimulator ~/Library/Developer/CoreSimulator`

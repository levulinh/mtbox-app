# Campaign Tracker — CTO Roadmap

_Last updated: 2026-04-04_

## Tech Stack
- Platform: Flutter (v3.41.4) + Dart — already established, cross-platform mobile
- State management: Riverpod — already in use, code-gen via `@riverpod`
- Local storage: Hive — already in use, no cloud for MVP
- Navigation: go_router — already in use, named routes
- Key packages: flutter_riverpod, hive_flutter, go_router, cupertino_icons

## Phase 1: MVP — Complete the core check-in loop
- [x] Daily check-in flow
- [x] Campaign detail screen
- [x] Edit & delete campaign
- [x] Campaign completion flow
- [x] Home screen with live data

## Phase 2: Engagement — Make progress feel real
- [x] Streak indicators on campaign cards
- [x] Activity history feed with real data
- [x] Stats dashboard (total campaigns, longest streak, completion rate)
- [x] Campaign archive (view completed campaigns)

## Phase 3: Polish — First-time and power-user experience
<!-- CEO directive (MTB-20): improve overall look & feel — softer brutalism, muted colors, less bold shadows, more visual delight -->
- [x] Onboarding flow for new users ← scheduled 2026-04-04
- [x] Local push notifications / daily reminders ← scheduled 2026-04-04
- [x] UI color palette refresh (softer brutalism — muted tones, reduced saturation) ← scheduled 2026-04-04
- [x] Shadow and border style refinement across all screens ← scheduled 2026-04-04
- [x] Visual delight polish (micro-interactions, empty states, subtle transitions) ← scheduled 2026-04-04
- [x] Custom campaign colors and icons ← scheduled 2026-04-04
- [x] Progress sharing (export screenshot) ← scheduled 2026-04-04

## Icebox (future ideas, not scheduled)
- [ ] Cloud sync across devices
- [ ] Multi-user / social accountability features
- [ ] Campaign templates library
- [ ] Apple Health / Google Fit integration

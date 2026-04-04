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
- [x] Streak indicators on campaign cards ← scheduled 2026-04-04
- [ ] Activity history feed with real data ← scheduled 2026-04-04
- [ ] Stats dashboard (total campaigns, longest streak, completion rate) ← scheduled 2026-04-04
- [ ] Campaign archive (view completed campaigns) ← scheduled 2026-04-04

## Phase 3: Polish — First-time and power-user experience
- [ ] Onboarding flow for new users
- [ ] Local push notifications / daily reminders
- [ ] Custom campaign colors and icons
- [ ] Progress sharing (export screenshot)

## Icebox (future ideas, not scheduled)
- [ ] Cloud sync across devices
- [ ] Multi-user / social accountability features
- [ ] Campaign templates library
- [ ] Apple Health / Google Fit integration

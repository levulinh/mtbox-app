# Campaign Tracker — CTO Roadmap

_Last updated: 2026-04-05_

## Tech Stack
- Platform: Flutter (v3.41.4) + Dart — already established, cross-platform mobile
- State management: Riverpod — already in use, code-gen via `@riverpod`
- Local storage: Hive — already in use for offline-first data layer
- Backend/Cloud: Supabase — Auth (email/password), PostgreSQL for cloud data, Realtime for sync
- Navigation: go_router — already in use, named routes
- Key packages: flutter_riverpod, hive_flutter, go_router, cupertino_icons, supabase_flutter

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

## Phase 4: Depth — Richer goal tracking and focus mode
<!-- CEO steering (MTB-10 mention 2026-04-04): onboarding data too overwhelming; add goal types beyond days; add focus session mode -->
- [x] Refined onboarding with realistic lightweight mock data
- [x] Flexible goal types (days, hours, sessions, or custom metric)
- [x] Focus session mode (distraction-free timer with auto-record to campaign)

## Phase 5: Cloud — Account management and cross-device sync
<!-- CEO steering (MTB-10 mention 2026-04-05): add account management and cloud synchronization using Supabase -->
- [x] Account registration and sign-in (Supabase Auth — email/password) ← scheduled 2026-04-05
- [x] User profile screen (display name, avatar, account settings) ← scheduled 2026-04-05
- [x] Cloud sync — upload local campaign data to Supabase on sign-in ← scheduled 2026-04-05
- [x] Real-time multi-device sync (changes reflect across devices instantly) ← scheduled 2026-04-05
- [x] Sign-out and data management (delete account, clear local data) ← scheduled 2026-04-05

## Icebox (future ideas, not scheduled)
- [ ] Multi-user / social accountability features
- [ ] Campaign templates library
- [ ] Apple Health / Google Fit integration

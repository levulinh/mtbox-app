# Programmer Agent Memory

## Purpose
Track architecture decisions, libraries used, patterns established, and things to avoid.

## Last Updated
2026-04-04

## Dependencies Added
| Package | Version | Reason | Date |
|---|---|---|---|
| flutter_riverpod | ^3.3.1 | State management | 2026-04-04 |
| riverpod_annotation | ^4.0.2 | Riverpod codegen support | 2026-04-04 |
| go_router | ^17.2.0 | Tab and page navigation | 2026-04-04 |

## Architecture Decisions
- **Riverpod with simple `Provider<T>`** for mock data (not `@riverpod` codegen) — keeping it simple until we need async/notifiers
- **go_router `ShellRoute`** wraps all 3 tabs so the bottom nav persists across tab switches
- **`NoTransitionPage`** used for tab routes to prevent slide animations between tabs
- **`brutalistBox()` helper in `lib/theme.dart`** — all card/container decoration goes through this to stay consistent
- **Theme defined in `lib/theme.dart`** — global constants (`kBlue`, `kBackground`, `kBlack`, `kBorderWidth`, `kShadowOffset`) used everywhere; never hardcode colors in widgets

## Patterns Established
- All screens: `Scaffold > SafeArea > CustomScrollView > SliverAppBar + SliverPadding`
- Bottom nav: custom `Row` of `_NavItem` widgets inside a `Container` with top border — NOT Flutter's built-in `BottomNavigationBar` (to match brutalism style exactly)
- Mock data lives in `lib/providers/mock_data_provider.dart` as simple `Provider<List<T>>` — move to Hive-backed `StateNotifier` when persistence is added
- Widgets > ~80 lines extracted to `lib/widgets/`
- `StatCard`, `ActivityItem`, `CampaignCard` are the core reusable widgets established

## Things to Avoid
- Don't use `setState` in screens — use Riverpod `ref.watch()`
- Don't use Flutter's `BottomNavigationBar` — the brutalism nav bar is custom
- Don't use `BorderRadius` anywhere — brutalism = zero radius
- Don't use `BoxShadow` with blurRadius > 0 — hard shadows only (`blurRadius: 0`)

## PRs Opened
| Date | PR URL | Issue | Status |
|---|---|---|---|
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/1 | MTB-6 | In Review |

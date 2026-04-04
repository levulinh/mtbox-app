# Programmer Agent Memory

## Purpose
Track architecture decisions, libraries used, patterns established, and things to avoid.

## Last Updated
2026-04-04 (run 24 — implemented MTB-19 campaign archive)

## Dependencies Added
| Package | Version | Reason | Date |
|---|---|---|---|
| flutter_riverpod | ^3.3.1 | State management | 2026-04-04 |
| riverpod_annotation | ^4.0.2 | Riverpod codegen support | 2026-04-04 |
| go_router | ^17.2.0 | Tab and page navigation | 2026-04-04 |
| hive_flutter | ^1.1.0 | Local persistence for campaign data | 2026-04-04 |

## Architecture Decisions
- **Riverpod 3.x uses `Notifier<T>` + `NotifierProvider`** — `StateNotifier` was removed in Riverpod 3. Use `class Foo extends Notifier<T>` with a `build()` method, and `NotifierProvider<Foo, T>(Foo.new)`. The `state` field works the same way inside the notifier.
- **Riverpod with simple `Provider<T>`** for read-only mock data; `NotifierProvider<T>` when mutations are needed (e.g. adding campaigns)
- **go_router `ShellRoute`** wraps all 3 tabs so the bottom nav persists across tab switches
- **`NoTransitionPage`** used for tab routes to prevent slide animations between tabs
- **`brutalistBox()` helper in `lib/theme.dart`** — all card/container decoration goes through this to stay consistent
- **Theme defined in `lib/theme.dart`** — global constants (`kBlue`, `kBackground`, `kBlack`, `kBorderWidth`, `kShadowOffset`) used everywhere; never hardcode colors in widgets
- **Hive persistence**: `main()` is `async`; call `WidgetsFlutterBinding.ensureInitialized()`, `await Hive.initFlutter()`, register adapters, `await Hive.openBox<T>(name)` — then `runApp`. Box is synchronously accessible everywhere after that.
- **Hive TypeAdapter**: use a manual `TypeAdapter<T>` (not build_runner codegen) — write fields sequentially in `write()`, read in the same order in `read()`. `typeId` must be unique across all registered adapters (Campaign = 0).
- **Hive box key strategy**: use the model's own `id` field as the Hive key (`box.put(model.id, model)`) so campaigns can be looked up or updated by id later.
- **Seed data on first launch**: if `box.isEmpty` in the notifier's `build()`, seed with mock data so existing integration tests (which expect `Morning Run`, `No Sugar` etc.) continue to pass.
- **Hive backward-compatible optional fields**: when adding a new field to a Hive model, check `reader.availableBytes > 0` before reading it so old persisted data still deserializes correctly. Write a bool sentinel (`hasField`) before the optional value so null is handled cleanly.
- **`ConsumerStatefulWidget` for local ephemeral state**: screens that need transient UI state (toast message, form validation) use `ConsumerStatefulWidget` + `setState` — Riverpod handles shared state, local widget `state` handles one-off display state.

## Patterns Established
- All screens: `Scaffold > SafeArea > CustomScrollView > SliverAppBar + SliverPadding`
- Bottom nav: custom `Row` of `_NavItem` widgets inside a `Container` with top border — NOT Flutter's built-in `BottomNavigationBar` (to match brutalism style exactly)
- Mock data lives in `lib/providers/mock_data_provider.dart`; read-only lists use `Provider<List<T>>`, mutable lists use `NotifierProvider<Notifier, List<T>>`
- **Form screens** use `ConsumerStatefulWidget` + local `bool _submitted` flag to gate validation display — only show errors after the first submit attempt
- Widgets > ~80 lines extracted to `lib/widgets/`
- `StatCard`, `ActivityItem`, `CampaignCard` are the core reusable widgets established
- **Section headers** (label + count, blue left border): built inline in the screen using a `Container` with `Border(left: BorderSide(color: kBlue, width: 3))` + `SliverChildListDelegate` — no dedicated widget needed for one-off headers
- **Empty state**: dashed-border `Container` (use `Color(0xFFCCCCCC)` border, not `brutalistBox`) inside `SliverFillRemaining(hasScrollBody: false)` 
- **Square icon-only FAB**: wrap `FloatingActionButton` in a sized `Container(decoration: brutalistBox(color: kBlue, filled: true))` with `backgroundColor: Colors.transparent, elevation: 0, shape: RoundedRectangleBorder()`
- **`brutalistBox(filled: true)` always fills kBlue** — to fill another color, build the `BoxDecoration` manually
- **In-list toast pattern**: to show a transient notification after a mutation, store a `String? _toastMessage` in `ConsumerStatefulWidget` state, render it as the first item in `SliverChildListDelegate` when non-null. Black background, blue left border (4px), `check_circle` icon + uppercase text matches the brutalism style.
- **`CampaignCard` check-in button**: active campaigns show a full-width blue "CHECK IN TODAY" button (`add_task` icon); after check-in it switches to a bordered "CHECKED IN TODAY" row (`check_circle` blue icon, no shadow, inert). Controlled via `Campaign.checkedInToday` getter.
- **Day tick gold highlight**: pass `showTodayTick: campaign.isActive && !campaign.checkedInToday` to `_DayTickStrip`; today index = `dayHistory.length`. Gold = `Color(0xFFFFD700)`.
- **Notifier mutation pattern**: `checkIn()` reads the campaign from Hive box, creates an updated copy (immutable model), puts it back, and sets `state = box.values.toList()` to trigger UI rebuild.

## Things to Avoid
- Don't use `setState` in screens — use Riverpod `ref.watch()` (exception: form screens use `ConsumerStatefulWidget` with `setState` only for local form validation state)
- Don't use `StateNotifier` — it was removed in Riverpod 3.x; use `Notifier` instead
- Don't use Flutter's `BottomNavigationBar` — the brutalism nav bar is custom
- Don't use `BorderRadius` anywhere — brutalism = zero radius
- Don't use `BoxShadow` with blurRadius > 0 — hard shadows only (`blurRadius: 0`)

- **Campaign detail route outside ShellRoute**: add `GoRoute(path: '/campaigns/:id')` at the TOP LEVEL (not inside `ShellRoute`) so the detail screen gets no bottom nav. go_router correctly prefers the more-specific `/campaigns/new` child under ShellRoute over the top-level `/:id` wildcard — no conflict.
- **Computed Campaign getters**: added `completedDays` and `currentStreak` as pure getters on the `Campaign` model (no Hive change needed — computed from `dayHistory`).
- **7-column day grid**: use `GridView.builder` with `crossAxisCount: 7`, `shrinkWrap: true`, `NeverScrollableScrollPhysics` inside a `SliverList` item. Each cell colored: blue=done, white/grey=missed, `Color(0xFFF0F0F0)`=future, today gets `kBlack` border at width 2.
- **Activity list date labels**: compute relative dates from `dayHistory` index using `DateTime.now().subtract(Duration(days: campaign.currentDay - dayNumber))` — no `startDate` field needed on the model.
- **GestureDetector on CampaignCard**: wrap the outer `Container` in a `GestureDetector(onTap: () => context.push('/campaigns/${campaign.id}'))` to navigate to detail. Import `go_router` in `campaign_card.dart`.
- **Edit route pattern**: edit screens live at `/campaigns/:id/edit` as a top-level GoRoute (outside ShellRoute) — same as the detail route pattern. `CampaignCard` has an edit icon button that uses `context.push('/campaigns/${campaign.id}/edit')`.
- **Edit screen pre-fill**: use `bool _initialized` flag in `ConsumerStatefulWidget` to populate `TextEditingController`s on first build when the campaign is available — avoids double-init and works with Riverpod reactive builds.
- **Delete confirmation dialog**: use `showDialog` with a custom `Dialog` widget (not `AlertDialog`). Build the dialog entirely with `Container` + `Column` to match brutalist border/shadow style. Use `Navigator.of(dialogContext).pop()` inside the dialog, then call `context.go('/campaigns')` after deletion.
- **`CampaignsNotifier.update()`**: takes `name` and `totalDays`, creates a full Campaign copy (immutable), puts it back in Hive by id, sets state. Also updates `goal` field to match `name` (they are kept in sync).
- **`CampaignsNotifier.delete()`**: calls `box.delete(campaignId)` then sets `state = box.values.toList()`.

## Patterns Established (continued)
- **Campaign completion flow**: `checkIn()` returns `bool` — `true` when `newCurrentDay >= totalDays`; sets `isActive: false` on completion. Calling widget checks return value and pushes `/campaigns/:id/complete` route. Completion screen is full-screen (no bottom nav), placed as top-level GoRoute outside ShellRoute.
- **`switch` expression in BoxDecoration color**: use Dart's `switch` expression pattern (`color: switch (type) { EnumVal => color, _ => fallback }`) for concise multi-case color selection in widget builds.
- **Test mock override**: when a notifier method signature changes (e.g., void → bool), update the mock subclass in `test/widget/` to match — the analyzer catches this as `invalid_override`.
- **Home screen live data pattern** (MTB-15): home screen reads `campaignsProvider` directly — no separate stats/feed providers needed. Compute `active`, `doneToday`, `bestStreak` inline in `build()`. This ensures any Hive mutation (create/edit/delete/check-in from any screen) is immediately reflected.
- **"Done Today" badge**: on the home screen, use a green fill (`Color(0xFF4AFF91)`) badge with black text when `campaign.checkedInToday`, replacing the blue "ACTIVE" badge. Consistent with mockup pattern.
- **Home card action row**: `Row` with `Expanded(_CheckInBtn or _ConfirmedRow)` + fixed-width `GestureDetector` detail chevron (40×40 brutalistBox). Different from Campaigns tab which uses full-width check-in and a separate edit icon.
- **`Colors.black.withAlpha(77)`** — use `withAlpha(int)` instead of deprecated `withOpacity(double)` for opacity in Flutter 3.x; `77 ≈ 0.3 * 255`.

## Patterns Established (continued)
- **Streak badge (MTB-16)**: use `Stack` + `Positioned(top: 10, right: 56)` to overlay the badge top-right of a campaign card. The `right: 56` offsets past the 32px edit icon + 14px card padding to avoid overlap. The name text inside `Expanded` gets `padding: EdgeInsets.only(right: 82)` when `campaign.hasStreak` to prevent text running under the badge.
- **`isStreakBroken` getter on Campaign**: checks if the day before the current streak run was a miss — `idx = dayHistory.length - currentStreak - 1; return idx >= 0 && !dayHistory[idx]`. False for empty history or unbroken-from-start streaks.
- **`streakDisplayCount`**: returns `max(1, currentStreak)` (never 0) — broken badge shows "1 DAY" to signal a fresh start.
- **`activityFeedProvider` real data (MTB-17)**: now watches `campaignsProvider` and derives entries from `dayHistory`. Anchor: `lastCheckInDate` parsed as `DateTime` for the last element; if missing, estimate from today. Each `dayHistory[i]` gets date `anchor - (history.length - 1 - i) days`. Active campaigns with no check-in today get a "Pending" entry dated today. Sort most-recent-first.
- **`ActivityEntry` optional fields**: `dayNumber`, `totalDays`, `isPending` all default to `0`/`false` for backward compat with existing tests that construct `ActivityEntry` with only the 3 required fields.
- **Home screen feed grouping**: use Dart 3 record tuples `(String, List<ActivityEntry>)` to carry `(dateLabel, entries)` groups built from the sorted feed. Use `DateTime(y,m,d)` equality (not `==` on full DateTime) to detect day boundaries.
- **Home screen greeting**: AppBar uses `RichText` inside `FlexibleSpaceBar` with `TextSpan` children; full text "HEY DREW" must match `find.text('HEY DREW', findRichText: true)` in widget tests.
- **"RECENT ACTIVITY" section header**: the home screen feed section must be labelled "RECENT ACTIVITY" (this is what the QA widget test `find.text('RECENT ACTIVITY')` checks for).
- **Stats dashboard (MTB-18)**: pushed screen at `/stats` (top-level GoRoute, no bottom nav). Stats computed inline from `campaignsProvider` — no separate provider needed. Longest streak = all-time best (max run in `dayHistory`), not current trailing streak. Abandoned = `!isActive && currentDay < totalDays`; Completed = `!isActive && currentDay >= totalDays`. Entry point: Profile tab → "Stats Dashboard" tappable row (`context.push('/stats')`).

- **Campaign archive screen (MTB-19)**: pushed screen at `/archive` (top-level GoRoute, no bottom nav). Entry point: "VIEW COMPLETED CAMPAIGNS" tappable banner in Campaigns tab — only shown when `completed.isNotEmpty`. Archive cards show: COMPLETED badge (black fill, no border), day-tick strip (black=done, white=missed, no border radius), 3-cell meta row, footer with date range + "View Details →" link to `/campaigns/:id`.
- **`bestStreak` getter on Campaign**: max consecutive run of `true` in `dayHistory` — different from `currentStreak` (trailing) and the `_computeStreak()` in provider (also trailing). Pure computed getter, no Hive impact.
- **Date range from `lastCheckInDate`**: end date = parsed `lastCheckInDate`; start = end − (totalDays − 1) days. Falls back to "Completed" if `lastCheckInDate` is null. Formatted as "Mon D, YYYY – Mon D, YYYY".
- **Archive entry point pattern**: rather than a nav tab, a tappable banner row inside the Campaigns tab `SliverList` (shown conditionally) routes to the archive. Keeps the nav tab count at 3.

## PRs Opened
| Date | PR URL | Issue | Status |
|---|---|---|---|
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/1 | MTB-6 | Done |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/2 | MTB-9 | Done |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/3 | MTB-8 | Done |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/4 | MTB-7 | Done |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/5 | MTB-11 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/6 | MTB-12 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/7 | MTB-13 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/8 | MTB-14 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/9 | MTB-15 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/10 | MTB-16 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/11 | MTB-17 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/12 | MTB-18 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/13 | MTB-19 | In Review |

# Programmer Agent Memory

## Purpose
Track architecture decisions, libraries used, patterns established, and things to avoid.

## Last Updated
2026-04-05 (run 35 — implemented MTB-31 account registration and sign-in)

## Dependencies Added
| Package | Version | Reason | Date |
|---|---|---|---|
| flutter_riverpod | ^3.3.1 | State management | 2026-04-04 |
| riverpod_annotation | ^4.0.2 | Riverpod codegen support | 2026-04-04 |
| go_router | ^17.2.0 | Tab and page navigation | 2026-04-04 |
| flutter_local_notifications | ^21.0.0 | Local push notifications | 2026-04-04 |
| timezone | ^0.11.0 | Required by flutter_local_notifications for zonedSchedule | 2026-04-04 |
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

- **Muted earthy palette (MTB-23)**: `kBlue=#4C6EAD`, `kBackground=#F7F3EF`, `kBlack=#2C2C2C`, `kWhite=#FFFDF9`. Added `kTextPrimary=#1A1A1A` (text), `kTextSecondary=#6B6B6B` (secondary labels), `kTerracotta=#B5735A` (accent). Use `kTextSecondary` instead of hardcoded `Color(0xFF555555)` or `Color(0xFF888888)` for secondary text.

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

- **Onboarding flow (MTB-21)**: `OnboardingScreen` is a 3-page `PageView` (no bottom nav) at top-level GoRoute `/onboarding`. First-launch detection: `Hive.box('settings').get('onboardingDone')` read synchronously after `await Hive.openBox('settings')` in `main()`.
- **Dynamic `initialLocation` pattern**: `router.dart` exports `createRouter(String initialLocation)` function instead of a top-level `router` constant — allows `main()` to decide `'/'` vs `'/onboarding'` before `runApp`. `MTBoxApp` takes `initialLocation` as required constructor param and calls `createRouter(initialLocation)`.
- **Widget tests referencing `MTBoxApp`** must pass `initialLocation: '/'` explicitly now that the param is required.
- **Onboarding completion**: sets `Hive.box('settings').put('onboardingDone', true)` then calls `context.go('/')`. Skip link also sets the flag. Campaign created in flow uses `DateTime.now().millisecondsSinceEpoch.toString()` as id.
- **`PageView` with no swipe**: use `physics: const NeverScrollableScrollPhysics()` so only programmatic navigation (buttons) advances screens. `PageController.animateToPage()` used for transitions.

- **Push notifications (MTB-22)**: `NotificationService` static class in `lib/services/notification_service.dart`. Uses `flutter_local_notifications` v21 (all args are named) + `timezone` for daily repeat.
- **flutter_local_notifications v21 API**: All methods use named params — `initialize(settings:, ...)`, `zonedSchedule(id:, scheduledDate:, notificationDetails:, androidScheduleMode:, title:, body:, payload:, matchDateTimeComponents:)`, `cancel(id:)`. Positional args removed in v21.
- **`tz.initializeTimeZones()` call**: call this inside `NotificationService.initialize()` (synchronous). Use `tz.TZDateTime.now(tz.local)` for current local time, `tz.TZDateTime(tz.local, y, m, d, h, min)` for the target. Add 1 day if target is already past.
- **Notification ID from campaign ID**: `campaignId.hashCode.abs() % 2147483647` — unique per campaign, stable across restarts, fits Android's int32 range.
- **Reminder state on Campaign**: `reminderEnabled` (bool, default false) + `reminderTime` (String? `"HH:mm"`, e.g. `"09:00"`) added as optional Hive fields using the backward-compat sentinel pattern from MTB-11.
- **Notification deep-link**: `NotificationService.onNotificationTap` is a static callback set in `_MTBoxAppState.initState` after creating the GoRouter; calls `_router.push('/campaigns/$campaignId')`. `MTBoxApp` is now `StatefulWidget` to hold the router instance.
- **`_ReminderSection` widget** (ConsumerWidget, inline in `campaign_detail_screen.dart`): brutalist toggle row, opacity-0.35 time row when disabled, active `showTimePicker` time row when enabled, blue info bar at card bottom. Calls `NotificationService.scheduleDaily()` / `.cancel()` after Hive state update.
- **`CampaignDetailScreen` → ConsumerStatefulWidget**: converted from ConsumerWidget to ConsumerStatefulWidget because _ReminderSection needs to be a child ConsumerWidget — both work fine as separate classes.

- **MTB-25 screen transitions**: Use `_slidePage(key, child)` helper in `router.dart` returning `CustomTransitionPage` with 250ms right-to-left slide + easeOut for all non-tab pushed routes. Tab routes keep `NoTransitionPage`.
- **MTB-25 animated progress bar**: `TweenAnimationBuilder<double>` wrapping `FractionallySizedBox` in `_ProgressBar` — animates 0→percent in 600ms `Curves.easeOutCubic`. Replace static fill to trigger on first build.
- **MTB-25 button press animation**: Convert `_CheckInButton` to `StatefulWidget` with `AnimationController` (80ms) + `ScaleTransition` — `onTapDown` forward, `onTapUp`/`onTapCancel` reverse. Target scale 0.96.
- **MTB-25 celebration toast**: Converted `_CheckInToast` to `StatefulWidget` with slide+fade-in (300ms easeOut). Add 24-square confetti strip above the message. Parent sets `Timer(2500ms)` to auto-dismiss. Also add `dispose()` + `_toastTimer?.cancel()` in the screen state.
- **MTB-25 empty state CTA**: Campaigns empty state uses `GestureDetector` + full-width blue `Container` navigating to `/campaigns/new`. Activity feed empty state adds "GO TO CAMPAIGNS →" nav link (required importing `go_router` in `home_screen.dart`).

- **MTB-24 shadow/border two-tier spec**: `kSoftBorderColor=#5A5A5A`, `kSoftBorderWidth=1.5`, `kSoftShadowColor=Color(0x732C2C2C)` (rgba(44,44,44,0.45)). `brutalistBox()` uses soft values. All content surfaces (cards, buttons, badges, progress bars, form fields) use soft values. Structural chrome (bottom nav top border, nav item separators, app bar bottom borders, onboarding page header borders) kept at `kBlack`/`kBorderWidth` (2px). Structural headers identifiable by `offset: Offset(0, 2)` downward shadow pattern.

- **MTB-26 campaign color/icon fields**: `colorHex` (String hex, no `#`, default `'4C6EAD'`) and `iconName` (String, default `'fitness_center'`) added to `Campaign`. Computed getters `campaignColor` (Color) and `iconData` (IconData) on the model — requires `import 'package:flutter/material.dart'` in campaign.dart.
- **Backward-compat Hive optional string fields**: for string optional fields (not nullable), read with `reader.readString()` directly (no bool sentinel needed) — only guard with `if (reader.availableBytes > 0)` block. This differs from nullable fields which use a bool `hasField` sentinel.
- **`kCampaignColorOptions`**: list of 8 hex strings (no `#`) in campaign.dart. `kCampaignIconOptions`: list of 8 `(name, IconData)` record tuples in campaign.dart.
- **`AppearancePickers` shared widget** (`lib/widgets/appearance_pickers.dart`): two 4-column `GridView.builder` (shrinkWrap + NeverScrollableScrollPhysics) for color swatches and icons. Selected color swatch shows check icon; selected icon cell fills with current accent color. Used in both Create and Edit campaign screens.
- **CampaignCard accent stripe**: outer `Container` now contains a `Row` — 4px `Container` in campaign color + `Expanded` card body. `Stack` wrapping the `Row` for streak badge overlay.
- **Campaign card icon box**: 40×40 `Container` with `color: campaign.campaignColor` and white icon inside — replaces the plain name text header; name + "DAY X OF Y" move to a `Column` next to the icon.
- **Progress bar fill color**: `_ProgressBar` now takes a `Color color` param — uses `color` for active campaigns (was always kBlue).
- **Day tick done color**: `_DayTickStrip` takes `Color color` param — done ticks use campaign color (was kBlue). Border for done/missed ticks softened to `kSoftBorderColor`.
- **Streak badge color**: stays fixed at `kBlue` regardless of campaign color — per design spec.
- **`CampaignsNotifier.update()` extended**: now accepts optional `colorHex` and `iconName` params (nullable, default null = keep existing). Also preserves `reminderEnabled`/`reminderTime` fields (fix: these were lost before). All other mutations (checkIn, setReminder) explicitly carry forward colorHex/iconName.

- **MTB-27 share progress screen**: `ShareProgressScreen` at `/campaigns/:id/share` (top-level GoRoute, no bottom nav). Entry point: `_ShareProgressButton` widget on campaign detail screen (between progress section and campaign days).
- **`screenshot` package (v3.0.0)**: wrap target widget in `Screenshot(controller: _controller, child: ...)`. Capture with `await controller.capture(pixelRatio: 3.0)` → `Uint8List?`.
- **`gal` package (v2.3.2)**: `await Gal.putImageBytes(bytes, name: 'filename')` to save to device gallery (no extension in name).
- **`share_plus` package (v12.0.2)**: write bytes to temp file via `path_provider` `getTemporaryDirectory()`, then `Share.shareXFiles([XFile(path, mimeType: 'image/png')])`.
- **Share card design**: 20px padding white container with 2px kBlack border + 4px offset shadow. Brand strip (bolt icon + MTBOX label + terracotta "Campaign Tracker" tag), 22px/900w campaign name, 54px big percentage + count block, 14px progress bar (2px kBlack border), `Wrap`-based tick strip (4px spacing), footer with kBlue streak badge + date. Uses kBlue for all progress elements (fixed brand color, not campaign color).
- **`Wrap` for tick strip in share card**: use `Wrap(spacing: 4, runSpacing: 4)` so ticks reflow naturally at any width without overflow.
- **`path_provider` package**: required for `getTemporaryDirectory()` when saving file for share_plus.

- **MTB-28 sample data pattern**: Sample campaigns use fixed IDs (`sample-read-daily`, `sample-exercise`) so they can be deleted by ID on dismiss. `hasSampleDataProvider` is a `NotifierProvider<SampleDataNotifier, bool>` reading from `Hive.box('settings')` key `hasSampleData`. `CampaignsNotifier.build()` sets `hasSampleData = true` when seeding. `CampaignsNotifier.dismissSamples()` deletes sample IDs and writes `false` to Hive. Home screen watches `hasSampleDataProvider` and conditionally renders the sample pill + welcome card.
- **Integration tests that use old seed data** (`Morning Run`, `No Sugar`) will need QA updates whenever seed data changes — this is expected.

- **MTB-29 flexible goal types**: `GoalType` enum (`days`, `hours`, `sessions`, `custom`) added to `campaign.dart`. New fields: `goalType` (default `GoalType.days`) and `metricName` (String, default `''`). Computed getters: `unitLabel` (e.g. `'DAYS'`, `'HRS'`, `'SESSIONS'`, uppercased metricName) and `checkInLabel` (`'CHECK IN TODAY'`, `'LOG HOURS'`, `'LOG SESSION'`, `'LOG PAGES'`).
- **`GoalTypeSelector` widget** (`lib/widgets/goal_type_selector.dart`): 4-cell brutalist segmented control (calendar_today / schedule / repeat / tune icons). Active cell fills kBlue; cells separated by `kSoftBorderColor` left borders. Outer container has `kSoftBorderColor` border + shadow.
- **`_GoalSection` pattern in Create/Edit screens**: replaces the old `_GoalField`. Contains `GoalTypeSelector` + amount input with dynamic unit pill + conditional Metric Name input (blue focused border, shown only when `goalType == GoalType.custom`). `_metricController` + `_metricError` validation added to both screens.
- **Hive backward-compat for MTB-29**: `goalType` stored as int (enum index via `writeInt(obj.goalType.index)`), `metricName` as string. Both read inside `if (reader.availableBytes > 0)` block. On read, clamp goalType index: `GoalType.values[index.clamp(0, GoalType.values.length - 1)]`.
- **All notifier mutations carry forward goalType + metricName**: `checkIn()`, `update()` (now accepts optional `goalType?` and `metricName?`), `setReminder()` all explicitly copy these fields.
- **Campaign card goal-type chip**: `_GoalTypeChip` widget — small grey `(icon + label)` chip in bottom-left of the name column. Uses Dart 3 switch expression with record destructuring `(IconData, String)`.
- **`_CheckInButton` now takes `label` param**: pass `campaign.checkInLabel` from `CampaignCard` to make the button label dynamic.

- **MTB-30 focus session mode**: `FocusSessionScreen` at `/campaigns/:id/focus` (top-level GoRoute, no bottom nav). Manages `_Phase` enum (`running` / `complete`) internally with a `Timer.periodic`. Captures campaign state snapshot (currentDay, totalDays, streak) *before* calling `checkIn()` so the completion screen can show accurate before→after comparison. Dark palette constants (`_kDark`, `_kDarkCard`, `_kDarkBorder`, `_kDarkSecondary`) are file-private — do not export. Uses `AnnotatedRegion<SystemUiOverlayStyle>` (import `package:flutter/services.dart`) for dark status/nav bar tinting.
- **Focus session CTA on detail screen**: "START FOCUS SESSION" button uses `brutalistBox()`-style border/shadow on `kBackground` fill (not blue) to visually distinguish it from the blue "SHARE MY PROGRESS" button above it. Only shown when `campaign.isActive && !campaign.checkedInToday`.
- **Duration picker dialog**: `showDialog` with custom `Dialog(backgroundColor: _kDarkCard)` + manual `Container` — matches dark theme. Options list (5/10/15/20/25/30/45/60 min). Selected option fills `kBlue`.

- **MTB-31 local auth pattern**: `UserAccount` model (typeId=1) with `email` + `password` stored in `Hive.box<UserAccount>('users')` keyed by normalized email. `AuthNotifier extends Notifier<AuthState>` with `signIn()`/`register()`/`clearError()` — stores `currentUser` email in `Hive.box('settings')`. Startup logic in `main()`: no `currentUser` → `/sign-in`, has user but no onboarding → `/onboarding`, fully onboarded → `/`.
- **Auth error state pattern**: `AuthState` carries `AuthError? error` (enum: `invalidCredentials`, `emailAlreadyInUse`). On error, Sign In button turns red + label → "TRY AGAIN"; error banner + red-bordered fields shown. `clearError()` called before each new submission and on field `onChanged`.
- **Shared auth widgets** (`lib/widgets/auth_widgets.dart`): `AuthField`, `AuthFieldLabel`, `AuthErrorBanner`, `AuthOrDivider`, `AuthSecurityNote`, `authFieldError()`. Use these for any future auth-related screens. `kAuthRed = Color(0xFFC0392B)` exported from this file.
- **Password strength bar**: 4-segment `Row` of `Container(height:3)` tiles. Score computed from: length≥6, has uppercase, has digit, has special char. Colors: 1=red, 2=orange, 3=green, 4=kBlue.
- **Auth routes outside ShellRoute**: `/sign-in` and `/register` are top-level GoRoutes (no bottom nav). `/register` pushed via `context.push()` from sign-in screen; "Sign In Instead" uses `context.pop()`.

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
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/14 | MTB-21 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/15 | MTB-22 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/16 | MTB-23 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/17 | MTB-24 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/18 | MTB-25 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/19 | MTB-26 | In Review |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/20 | MTB-27 | In Review |
| 2026-04-05 | https://github.com/levulinh/mtbox-app/pull/21 | MTB-28 | In Review |
| 2026-04-05 | https://github.com/levulinh/mtbox-app/pull/22 | MTB-29 | In Review |
| 2026-04-05 | https://github.com/levulinh/mtbox-app/pull/23 | MTB-30 | In Review |
| 2026-04-05 | https://github.com/levulinh/mtbox-app/pull/24 | MTB-31 | In Review |

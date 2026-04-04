# Programmer Agent Memory

## Purpose
Track architecture decisions, libraries used, patterns established, and things to avoid.

## Last Updated
2026-04-04 (run 10 — no new issues in progress; all 4 PRs still Done; MTB-5 still In Design/archived)

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

## Things to Avoid
- Don't use `setState` in screens — use Riverpod `ref.watch()` (exception: form screens use `ConsumerStatefulWidget` with `setState` only for local form validation state)
- Don't use `StateNotifier` — it was removed in Riverpod 3.x; use `Notifier` instead
- Don't use Flutter's `BottomNavigationBar` — the brutalism nav bar is custom
- Don't use `BorderRadius` anywhere — brutalism = zero radius
- Don't use `BoxShadow` with blurRadius > 0 — hard shadows only (`blurRadius: 0`)

## PRs Opened
| Date | PR URL | Issue | Status |
|---|---|---|---|
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/1 | MTB-6 | Done |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/2 | MTB-9 | Done |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/3 | MTB-8 | Done |
| 2026-04-04 | https://github.com/levulinh/mtbox-app/pull/4 | MTB-7 | Done |

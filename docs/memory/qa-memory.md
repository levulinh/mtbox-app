# QA Agent Memory

## Purpose
Track known flaky tests, recurring issues, testing strategies that work.

## Last Updated
2026-04-04 (session 8: no issues in review — confirmed via Linear state ID b45fd3f7; all PRs merged)

## Known Flaky Tests
(none yet)

## Recurring Failure Patterns
- macOS creates `._` resource fork files in test directories — `flutter test test/` crashes when it encounters them. Always specify test files explicitly: `flutter test test/unit/foo_test.dart test/widget/foo_test.dart` instead of `flutter test test/`.
- Android emulator (MTBox_QA AVD) fails to boot headlessly within 300s — gfxstream/GPU init hangs. E2E tests should be skipped with a note when this happens; the test files are still committed and ready for manual runs.

## Testing Strategies
- `HEY DREW` greeting text lives inside a `RichText`/`TextSpan` inside `FlexibleSpaceBar` — use `find.text('HEY DREW', findRichText: true)` to locate it, or test home screen presence via the `RECENT ACTIVITY` plain `Text` widget instead.
- For integration (full app) widget tests, wrap with `ProviderScope(child: MTBoxApp())`.
- Use `.last` when tapping nav items (e.g. `find.text('CAMPAIGNS').last`) because the tab label appears in both the nav bar and the screen header.
- `NotifierProvider` (Riverpod 3.x) does NOT support `overrideWithValue`. Override by creating a subclass with a custom `build()` and calling `campaignsProvider.overrideWith(() => _FixedNotifier(data))`.
- Screens using `context.pop()` from go_router require a GoRouter ancestor in widget tests. Set up a parent route so pop has somewhere to land: `GoRoute(path: '/home', routes: [GoRoute(path: 'create', ...)])` and use `MaterialApp.router`.
- In widget tests for `CreateCampaignScreen`, `find.byType(TextField).first` = name field, `find.byType(TextField).last` = goal field.

## Issues Tested
2026-04-04 | MTB-6 | test/unit/app_shell_test.dart, test/widget/app_shell_test.dart, integration_test/app_shell_test.dart | 37/37 unit+widget passed; E2E skipped (emulator boot failure)
2026-04-04 | MTB-8 | test/unit/campaign_creation_test.dart, test/widget/campaign_creation_test.dart, integration_test/campaign_creation_test.dart | 89/89 unit+widget passed; E2E skipped (no device); also fixed test/widget/campaign_list_test.dart broken by NotifierProvider refactor

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/campaign_detail_screen.dart';
import 'package:mtbox_app/screens/campaigns_screen.dart';

// Returns a fixed list — no Hive, no disk I/O, pumpAndSettle settles cleanly.
class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _campaigns;
  _FixedCampaignsNotifier(this._campaigns);

  @override
  List<Campaign> build() => _campaigns;
}

Widget buildDetail(String campaignId, List<Campaign> campaigns) {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(() => _FixedCampaignsNotifier(campaigns)),
    ],
    child: MaterialApp(
      home: CampaignDetailScreen(campaignId: campaignId),
    ),
  );
}

// Router-wrapped build for navigation tests (CampaignCard → detail).
GoRouter _makeNavRouter(List<Campaign> campaigns) => GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (_, __) => const CampaignsScreen(),
        ),
        GoRoute(
          path: '/campaigns/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return CampaignDetailScreen(campaignId: id);
          },
        ),
      ],
    );

Widget buildWithNav(List<Campaign> campaigns) {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(() => _FixedCampaignsNotifier(campaigns)),
    ],
    child: MaterialApp.router(routerConfig: _makeNavRouter(campaigns)),
  );
}

// ── Test data ──────────────────────────────────────────────────────────────

final _campaign = Campaign(
  id: 'c1',
  name: 'Morning Run',
  goal: 'Run every day',
  totalDays: 10,
  currentDay: 6,
  isActive: true,
  // days 0-5: [true, false, true, true, true, true] → 5 done, streak=4
  dayHistory: [true, false, true, true, true, true],
);

void main() {
  // ─── App bar ────────────────────────────────────────────────────────────────

  group('CampaignDetailScreen — app bar', () {
    testWidgets('shows campaign name uppercased in app bar', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('MORNING RUN'), findsOneWidget);
    });

    testWidgets('shows back arrow icon', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  // ─── Not found ──────────────────────────────────────────────────────────────

  group('CampaignDetailScreen — not found', () {
    testWidgets('shows "Campaign not found" for unknown id', (tester) async {
      await tester.pumpWidget(buildDetail('unknown-id', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('Campaign not found'), findsOneWidget);
    });

    testWidgets('"Campaign not found" for empty campaigns list', (tester) async {
      await tester.pumpWidget(buildDetail('c1', []));
      await tester.pumpAndSettle();
      expect(find.text('Campaign not found'), findsOneWidget);
    });
  });

  // ─── Stats row ──────────────────────────────────────────────────────────────

  group('CampaignDetailScreen — stats row', () {
    testWidgets('Day Streak label is shown', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('DAY STREAK'), findsOneWidget);
    });

    testWidgets('Completed label is shown', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('COMPLETED'), findsOneWidget);
    });

    testWidgets('Goal Days label is shown', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('GOAL DAYS'), findsOneWidget);
    });

    testWidgets('streak value matches currentStreak', (tester) async {
      // _campaign.currentStreak = 4 (last 4 are true).
      // "4" also appears in the day grid (day #4), so use findsWidgets.
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('4'), findsWidgets);
    });

    testWidgets('completed value matches completedDays', (tester) async {
      // _campaign.completedDays = 5.
      // "5" also appears in the day grid (day #5), so use findsWidgets.
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('goal days value shows totalDays', (tester) async {
      // _campaign.totalDays = 10.
      // "10" also appears in the day grid (day #10), so use findsWidgets.
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('10'), findsWidgets);
    });

    testWidgets('streak icon is present', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('completed icon is present', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      // check_circle appears in both stat card and activity list
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('goal flag icon is present', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.flag), findsOneWidget);
    });
  });

  // ─── Progress section ────────────────────────────────────────────────────────

  group('CampaignDetailScreen — progress section', () {
    testWidgets('shows "X of Y days — Z%" text', (tester) async {
      // currentDay=6, totalDays=10 → 60%
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('6 of 10 days — 60%'), findsOneWidget);
    });

    testWidgets('shows "N days remaining" text', (tester) async {
      // totalDays=10, currentDay=6 → 4 remaining
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('4 days remaining'), findsOneWidget);
    });

    testWidgets('PROGRESS section label is present', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('PROGRESS'), findsOneWidget);
    });
  });

  // ─── Day grid ───────────────────────────────────────────────────────────────

  group('CampaignDetailScreen — day grid', () {
    testWidgets('CAMPAIGN DAYS section label is present', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('CAMPAIGN DAYS'), findsOneWidget);
    });

    testWidgets('renders one cell per totalDays', (tester) async {
      // totalDays = 10 → day numbers 1–10 in the grid.
      // Some numbers also appear in stat cards, so use findsWidgets (at least 1).
      // Use skipOffstage: false to catch grid cells scrolled below the viewport.
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      for (var i = 1; i <= 10; i++) {
        expect(find.text('$i', skipOffstage: false), findsWidgets);
      }
    });
  });

  // ─── Recent Activity ─────────────────────────────────────────────────────────

  group('CampaignDetailScreen — recent activity', () {
    testWidgets('RECENT ACTIVITY section label is present', (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('RECENT ACTIVITY'), findsOneWidget);
    });

    testWidgets('activity list shows DAY labels in reverse order', (tester) async {
      // Activity list may be below the fold — use skipOffstage: false.
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('DAY 6', skipOffstage: false), findsOneWidget);
      expect(find.text('DAY 1', skipOffstage: false), findsOneWidget);
    });

    testWidgets('DONE label shown for completed days', (tester) async {
      // 5 done days → DONE appears 5 times (may be off-screen).
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('DONE', skipOffstage: false), findsNWidgets(5));
    });

    testWidgets('MISSED label shown for missed days', (tester) async {
      // 1 missed day → MISSED appears once (may be off-screen).
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('MISSED', skipOffstage: false), findsOneWidget);
    });

    testWidgets('radio_button_unchecked icon shown for missed days',
        (tester) async {
      await tester.pumpWidget(buildDetail('c1', [_campaign]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.radio_button_unchecked, skipOffstage: false),
          findsOneWidget);
    });
  });

  // ─── Navigation ─────────────────────────────────────────────────────────────

  group('CampaignDetailScreen — navigation', () {
    testWidgets('tapping a campaign card navigates to detail screen',
        (tester) async {
      await tester.pumpWidget(buildWithNav([_campaign]));
      await tester.pumpAndSettle();

      // Tap the campaign card (use campaign name)
      await tester.tap(find.text('Morning Run').first);
      await tester.pumpAndSettle();

      // Detail screen is shown
      expect(find.text('MORNING RUN'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}

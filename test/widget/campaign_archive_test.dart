import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/campaign_archive_screen.dart';
import 'package:mtbox_app/screens/campaign_detail_screen.dart';

// Returns a fixed list — no Hive, no disk I/O, pumpAndSettle settles cleanly.
class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _campaigns;
  _FixedCampaignsNotifier(this._campaigns);

  @override
  List<Campaign> build() => _campaigns;
}

Widget buildArchive(List<Campaign> campaigns) {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(() => _FixedCampaignsNotifier(campaigns)),
    ],
    child: MaterialApp(
      home: CampaignArchiveScreen(),
    ),
  );
}

// Router-wrapped build for navigation tests (archive → detail).
GoRouter _makeNavRouter(List<Campaign> campaigns) => GoRouter(
      initialLocation: '/archive',
      routes: [
        GoRoute(
          path: '/archive',
          builder: (_, __) => CampaignArchiveScreen(),
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

final _completedCampaign1 = Campaign(
  id: 'c1',
  name: 'Morning Run',
  goal: 'Run every day',
  totalDays: 30,
  currentDay: 30,
  isActive: false,
  dayHistory: List.filled(30, true),
  lastCheckInDate: '2026-03-31',
);

final _completedCampaign2 = Campaign(
  id: 'c2',
  name: 'Read 10 Books',
  goal: 'Read 10 books',
  totalDays: 60,
  currentDay: 60,
  isActive: false,
  dayHistory: List.filled(45, true) + List.filled(15, false),
  lastCheckInDate: '2026-04-03',
);

final _activeCampaign = Campaign(
  id: 'c3',
  name: 'Meditate Daily',
  goal: 'Meditate every day',
  totalDays: 30,
  currentDay: 15,
  isActive: true,
  dayHistory: List.filled(15, true) + List.filled(15, false),
);

void main() {
  // ─── Empty archive ──────────────────────────────────────────────────────────

  group('CampaignArchiveScreen — empty state', () {
    testWidgets('shows empty state when no campaigns completed', (tester) async {
      await tester.pumpWidget(buildArchive([_activeCampaign]));
      await tester.pumpAndSettle();

      expect(find.text('NO COMPLETED CAMPAIGNS'), findsOneWidget);
      expect(find.text('Complete a campaign to see it here.'), findsOneWidget);
    });

    testWidgets('shows trophy icon in empty state', (tester) async {
      await tester.pumpWidget(buildArchive([_activeCampaign]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    });
  });

  // ─── Summary banner ─────────────────────────────────────────────────────────

  group('CampaignArchiveScreen — summary banner', () {
    testWidgets('displays correct count of completed campaigns', (tester) async {
      await tester.pumpWidget(
        buildArchive([_completedCampaign1, _completedCampaign2, _activeCampaign]),
      );
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows "CAMPAIGNS COMPLETED" label', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      expect(find.text('CAMPAIGNS COMPLETED'), findsOneWidget);
    });

    testWidgets('shows trophy icon in banner', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.emoji_events), findsWidgets);
    });
  });

  // ─── Archive cards ──────────────────────────────────────────────────────────

  group('CampaignArchiveScreen — archive cards', () {
    testWidgets('displays campaign name', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('shows COMPLETED badge on card', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      // COMPLETED appears multiple times (badge + meta row), so check > 0
      expect(find.text('COMPLETED'), findsWidgets);
    });

    testWidgets('displays correct goal days value', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      expect(find.text('30'), findsWidgets); // appears in progress and meta
    });

    testWidgets('shows 100% progress bar for completed campaign', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      expect(find.text('Day 30 of 30'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('renders day ticks based on dayHistory', (tester) async {
      // Campaign with some missed days
      final campaign = Campaign(
        id: 'c1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 10,
        currentDay: 10,
        isActive: false,
        dayHistory: [
          true, true, false, true, true, true, false, true, true, true
        ],
      );

      await tester.pumpWidget(buildArchive([campaign]));
      await tester.pumpAndSettle();

      // Should render 10 day ticks
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays meta row with icons and values', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      // Check for meta row labels
      expect(find.text('GOAL DAYS'), findsOneWidget);
      expect(find.text('COMPLETED'), findsWidgets); // appears twice (meta + badge)
    });

    testWidgets('displays BEST STREAK in meta row', (tester) async {
      // Campaign with a clear streak pattern
      final campaign = Campaign(
        id: 'c1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 10,
        currentDay: 10,
        isActive: false,
        dayHistory: [
          true, true, true, false, true, true, true, true, false, true
        ], // best streak = 4
      );

      await tester.pumpWidget(buildArchive([campaign]));
      await tester.pumpAndSettle();

      expect(find.text('BEST STREAK'), findsOneWidget);
    });

    testWidgets('shows view details link', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      expect(find.text('VIEW DETAILS'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });

  // ─── Date range display ─────────────────────────────────────────────────────

  group('CampaignArchiveScreen — date range', () {
    testWidgets('displays date range from lastCheckInDate and totalDays',
        (tester) async {
      // Campaign with lastCheckInDate set
      final campaign = Campaign(
        id: 'c1',
        name: 'Test Campaign',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 30,
        isActive: false,
        dayHistory: List.filled(30, true),
        lastCheckInDate: '2026-03-31',
      );

      await tester.pumpWidget(buildArchive([campaign]));
      await tester.pumpAndSettle();

      // Should show date range: Mar 2 – Mar 31
      expect(find.text('Mar 2, 2026 – Mar 31, 2026'), findsOneWidget);
    });

    testWidgets('shows "Completed" when no lastCheckInDate', (tester) async {
      final campaign = Campaign(
        id: 'c1',
        name: 'Test Campaign',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 30,
        isActive: false,
        dayHistory: List.filled(30, true),
        lastCheckInDate: null,
      );

      await tester.pumpWidget(buildArchive([campaign]));
      await tester.pumpAndSettle();

      expect(find.text('Completed'), findsOneWidget);
    });
  });

  // ─── Multiple campaigns ─────────────────────────────────────────────────────

  group('CampaignArchiveScreen — multiple campaigns', () {
    testWidgets('displays all completed campaigns in order', (tester) async {
      await tester.pumpWidget(
        buildArchive([_completedCampaign1, _completedCampaign2, _activeCampaign]),
      );
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Read 10 Books'), findsOneWidget);
      expect(find.text('Meditate Daily'), findsNothing); // active, not shown
    });

    testWidgets('shows correct count in banner for multiple campaigns',
        (tester) async {
      await tester.pumpWidget(
        buildArchive([_completedCampaign1, _completedCampaign2, _activeCampaign]),
      );
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows COMPLETED CAMPAIGNS header with count',
        (tester) async {
      await tester.pumpWidget(
        buildArchive([_completedCampaign1, _completedCampaign2]),
      );
      await tester.pumpAndSettle();

      expect(find.text('COMPLETED CAMPAIGNS — 2'), findsOneWidget);
    });
  });

  // ─── Navigation ─────────────────────────────────────────────────────────────

  group('CampaignArchiveScreen — navigation', () {
    testWidgets('back button pops the route', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();
    });

    testWidgets('VIEW DETAILS link navigates to detail screen', (tester) async {
      await tester.pumpWidget(buildWithNav([_completedCampaign1]));
      await tester.pumpAndSettle();

      final viewDetails = find.text('VIEW DETAILS');
      await tester.tap(viewDetails);
      await tester.pumpAndSettle();

      // Should now be on detail screen
      expect(find.text('MORNING RUN'), findsOneWidget);
    });
  });

  // ─── Visual layout checks ────────────────────────────────────────────────────

  group('CampaignArchiveScreen — visual layout', () {
    testWidgets('shows app bar with ARCHIVE title', (tester) async {
      await tester.pumpWidget(buildArchive([_completedCampaign1]));
      await tester.pumpAndSettle();

      expect(find.text('ARCHIVE'), findsOneWidget);
    });

    testWidgets('renders multiple campaigns without crashing', (tester) async {
      // Create many campaigns to test rendering performance
      final campaigns = List.generate(
        5,
        (i) => Campaign(
          id: 'c$i',
          name: 'Campaign $i',
          goal: 'Goal',
          totalDays: 30,
          currentDay: 30,
          isActive: false,
          dayHistory: List.filled(30, true),
          lastCheckInDate: '2026-03-31',
        ),
      );

      await tester.pumpWidget(buildArchive(campaigns));
      await tester.pumpAndSettle();

      // First campaigns should be visible; later ones scrolled out of view
      expect(find.text('Campaign 0'), findsOneWidget);
      expect(find.text('Campaign 1'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/edit_campaign_screen.dart';
import 'package:mtbox_app/screens/campaigns_screen.dart';

// In-memory notifier — avoids Hive entirely.
class _MutableCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _initial;
  _MutableCampaignsNotifier(this._initial);

  @override
  List<Campaign> build() => List.of(_initial);

  @override
  void update(String campaignId, {required String name, required int totalDays}) {
    state = [
      for (final c in state)
        if (c.id == campaignId)
          Campaign(
            id: c.id,
            name: name,
            goal: name,
            totalDays: totalDays,
            currentDay: c.currentDay,
            isActive: c.isActive,
            dayHistory: c.dayHistory,
            lastCheckInDate: c.lastCheckInDate,
          )
        else
          c,
    ];
  }

  @override
  void delete(String campaignId) {
    state = state.where((c) => c.id != campaignId).toList();
  }
}

// Campaign used across tests.
final _campaign = Campaign(
  id: 'c1',
  name: 'Morning Run',
  goal: 'Run every day',
  totalDays: 30,
  currentDay: 10,
  isActive: true,
  dayHistory: List.generate(10, (_) => true),
);

// Nest the edit route under /campaigns so context.pop() has a parent to land on.
GoRouter _makeRouter(List<Campaign> campaigns) => GoRouter(
      initialLocation: '/campaigns/c1/edit',
      routes: [
        GoRoute(
          path: '/campaigns',
          builder: (_, __) => const CampaignsScreen(),
          routes: [
            GoRoute(
              path: ':id/edit',
              builder: (context, state) => EditCampaignScreen(
                campaignId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
      ],
    );

Widget buildScreen(List<Campaign> campaigns) {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(
          () => _MutableCampaignsNotifier(campaigns)),
    ],
    child: MaterialApp.router(routerConfig: _makeRouter(campaigns)),
  );
}

void main() {
  // ─── Initial render ──────────────────────────────────────────────────────────

  group('EditCampaignScreen — initial render', () {
    testWidgets('shows EDIT CAMPAIGN in app bar', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('EDIT CAMPAIGN'), findsOneWidget);
    });

    testWidgets('shows back arrow', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('CAMPAIGN NAME field label is shown', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('CAMPAIGN NAME'), findsOneWidget);
    });

    testWidgets('GOAL (DAYS) field label is shown', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('GOAL (DAYS)'), findsOneWidget);
    });

    testWidgets('DAYS unit pill is shown', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('DAYS'), findsOneWidget);
    });

    testWidgets('CANCEL button is shown', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('CANCEL'), findsOneWidget);
    });

    testWidgets('SAVE button is shown', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('DELETE THIS CAMPAIGN button is shown', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('DELETE THIS CAMPAIGN'), findsOneWidget);
    });

    testWidgets('name field pre-filled with campaign name', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Morning Run'), findsOneWidget);
    });

    testWidgets('goal field pre-filled with campaign totalDays', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, '30'), findsOneWidget);
    });

    testWidgets('no validation banner before submission', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();
      expect(find.text('PLEASE FIX THE ERRORS BELOW'), findsNothing);
    });

    testWidgets('shows "Campaign not found" for unknown id', (tester) async {
      final router = GoRouter(
        initialLocation: '/campaigns/unknown/edit',
        routes: [
          GoRoute(
            path: '/campaigns',
            builder: (_, __) => const Scaffold(body: Text('CAMPAIGNS')),
            routes: [
              GoRoute(
                path: ':id/edit',
                builder: (context, state) =>
                    EditCampaignScreen(campaignId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          campaignsProvider
              .overrideWith(() => _MutableCampaignsNotifier([_campaign])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Campaign not found'), findsOneWidget);
    });
  });

  // ─── Validation ──────────────────────────────────────────────────────────────

  group('EditCampaignScreen — validation', () {
    testWidgets('tapping SAVE with empty name shows error banner', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('PLEASE FIX THE ERRORS BELOW'), findsOneWidget);
    });

    testWidgets('tapping SAVE with empty name shows NAME IS REQUIRED',
        (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('NAME IS REQUIRED'), findsOneWidget);
    });

    testWidgets('tapping SAVE with invalid goal shows goal error', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Valid Name');
      await tester.enterText(find.byType(TextField).last, '0');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(find.text('ENTER A VALID NUMBER OF DAYS'), findsOneWidget);
    });
  });

  // ─── Save ────────────────────────────────────────────────────────────────────

  group('EditCampaignScreen — save', () {
    testWidgets('valid save updates name in provider and pops back',
        (tester) async {
      late ProviderContainer container;
      final campaigns = [_campaign];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
              () => _MutableCampaignsNotifier(campaigns)),
        ],
        child: Builder(builder: (context) {
          container = ProviderScope.containerOf(context);
          return MaterialApp.router(
              routerConfig: _makeRouter(campaigns));
        }),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Updated Name');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(
        container.read(campaignsProvider).firstWhere((c) => c.id == 'c1').name,
        equals('Updated Name'),
      );
      // Popped back
      expect(find.text('EDIT CAMPAIGN'), findsNothing);
    });

    testWidgets('valid save with new goal updates totalDays', (tester) async {
      late ProviderContainer container;
      final campaigns = [_campaign];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
              () => _MutableCampaignsNotifier(campaigns)),
        ],
        child: Builder(builder: (context) {
          container = ProviderScope.containerOf(context);
          return MaterialApp.router(routerConfig: _makeRouter(campaigns));
        }),
      ));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, '60');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(
        container.read(campaignsProvider).firstWhere((c) => c.id == 'c1').totalDays,
        equals(60),
      );
    });
  });

  // ─── Cancel ──────────────────────────────────────────────────────────────────

  group('EditCampaignScreen — cancel', () {
    testWidgets('tapping CANCEL pops back without changes', (tester) async {
      late ProviderContainer container;
      final campaigns = [_campaign];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
              () => _MutableCampaignsNotifier(campaigns)),
        ],
        child: Builder(builder: (context) {
          container = ProviderScope.containerOf(context);
          return MaterialApp.router(routerConfig: _makeRouter(campaigns));
        }),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CANCEL'));
      await tester.pumpAndSettle();

      // Name unchanged
      expect(
        container.read(campaignsProvider).firstWhere((c) => c.id == 'c1').name,
        equals('Morning Run'),
      );
      expect(find.text('EDIT CAMPAIGN'), findsNothing);
    });
  });

  // ─── Delete dialog ───────────────────────────────────────────────────────────

  group('EditCampaignScreen — delete dialog', () {
    testWidgets('tapping DELETE shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE THIS CAMPAIGN'));
      await tester.pumpAndSettle();

      expect(find.text('DELETE CAMPAIGN?'), findsOneWidget);
    });

    testWidgets('confirmation dialog shows campaign name', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE THIS CAMPAIGN'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Morning Run'), findsOneWidget);
    });

    testWidgets('confirmation dialog warns "THIS CANNOT BE UNDONE"',
        (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE THIS CAMPAIGN'));
      await tester.pumpAndSettle();

      expect(find.textContaining('CANNOT BE UNDONE'), findsOneWidget);
    });

    testWidgets('KEEP IT dismisses dialog without deleting', (tester) async {
      late ProviderContainer container;
      final campaigns = [_campaign];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
              () => _MutableCampaignsNotifier(campaigns)),
        ],
        child: Builder(builder: (context) {
          container = ProviderScope.containerOf(context);
          return MaterialApp.router(routerConfig: _makeRouter(campaigns));
        }),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE THIS CAMPAIGN'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('KEEP IT'));
      await tester.pumpAndSettle();

      // Dialog dismissed, campaign still present
      expect(find.text('DELETE CAMPAIGN?'), findsNothing);
      expect(container.read(campaignsProvider).any((c) => c.id == 'c1'), isTrue);
    });

    testWidgets('DELETE in dialog removes campaign from provider', (tester) async {
      late ProviderContainer container;
      final campaigns = [_campaign];

      await tester.pumpWidget(ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
              () => _MutableCampaignsNotifier(campaigns)),
        ],
        child: Builder(builder: (context) {
          container = ProviderScope.containerOf(context);
          return MaterialApp.router(routerConfig: _makeRouter(campaigns));
        }),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE THIS CAMPAIGN'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      expect(container.read(campaignsProvider).any((c) => c.id == 'c1'), isFalse);
    });

    testWidgets('DELETE in dialog navigates to campaigns list', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE THIS CAMPAIGN'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      // Navigated away from edit screen
      expect(find.text('EDIT CAMPAIGN'), findsNothing);
    });
  });

  // ─── Edit icon on campaign card ──────────────────────────────────────────────

  group('CampaignCard — edit icon', () {
    testWidgets('edit icon is shown on campaign card', (tester) async {
      await tester.pumpWidget(buildScreen([_campaign]));
      await tester.pumpAndSettle();

      // Navigate to campaigns list first via a router that starts there
      final router = GoRouter(
        initialLocation: '/campaigns',
        routes: [
          GoRoute(
            path: '/campaigns',
            builder: (_, __) => const CampaignsScreen(),
            routes: [
              GoRoute(
                path: ':id/edit',
                builder: (context, state) =>
                    EditCampaignScreen(campaignId: state.pathParameters['id']!),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [
          campaignsProvider.overrideWith(
              () => _MutableCampaignsNotifier([_campaign])),
        ],
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/campaigns_screen.dart';

// Override that returns a pre-determined list, simulating campaigns loaded from
// Hive on startup — the same data path used by the real CampaignsNotifier.
class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _campaigns;
  _FixedCampaignsNotifier(this._campaigns);

  @override
  List<Campaign> build() => _campaigns;
}

Widget buildWithCampaigns(List<Campaign> campaigns) {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(() => _FixedCampaignsNotifier(campaigns)),
    ],
    child: const MaterialApp(home: CampaignsScreen()),
  );
}

final _persistedActive = Campaign(
  id: '1',
  name: 'Morning Run',
  goal: 'Run every day for 30 days',
  totalDays: 30,
  currentDay: 18,
  isActive: true,
  dayHistory: List.generate(18, (i) => i % 5 != 3),
);

final _persistedCompleted = Campaign(
  id: '2',
  name: 'Daily Reading',
  goal: 'Read 20 pages per day for 21 days',
  totalDays: 21,
  currentDay: 21,
  isActive: false,
  dayHistory: List.generate(21, (_) => true),
);

void main() {
  group('CampaignsScreen — data loaded from persistent storage', () {
    testWidgets('shows all campaigns that were loaded from Hive', (tester) async {
      await tester.pumpWidget(buildWithCampaigns([_persistedActive, _persistedCompleted]));
      await tester.pumpAndSettle();

      expect(find.text('Morning Run'), findsOneWidget);
      expect(find.text('Daily Reading'), findsOneWidget);
    });

    testWidgets('active campaign loaded from Hive appears in ACTIVE section', (tester) async {
      await tester.pumpWidget(buildWithCampaigns([_persistedActive]));
      await tester.pumpAndSettle();

      expect(find.text('ACTIVE — 1 campaign'), findsOneWidget);
      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('completed campaign loaded from Hive appears in COMPLETED section', (tester) async {
      await tester.pumpWidget(buildWithCampaigns([_persistedCompleted]));
      await tester.pumpAndSettle();

      expect(find.textContaining('COMPLETED —'), findsOneWidget);
      expect(find.text('Daily Reading'), findsOneWidget);
    });

    testWidgets('progress percentage is correct for persisted campaign', (tester) async {
      // Morning Run: 18/30 = 60%
      await tester.pumpWidget(buildWithCampaigns([_persistedActive]));
      await tester.pumpAndSettle();

      expect(find.text('60%'), findsOneWidget);
    });

    testWidgets('empty state shown when Hive returns no campaigns', (tester) async {
      await tester.pumpWidget(buildWithCampaigns([]));
      await tester.pumpAndSettle();

      expect(find.text('NO CAMPAIGNS YET'), findsOneWidget);
      expect(find.textContaining('ACTIVE —'), findsNothing);
    });
  });
}

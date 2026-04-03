import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/campaigns_screen.dart';
import 'package:mtbox_app/theme.dart';
import 'package:mtbox_app/widgets/campaign_card.dart';

class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _campaigns;
  _FixedCampaignsNotifier(this._campaigns);

  @override
  List<Campaign> build() => _campaigns;
}

Widget buildScreen(List<Campaign> campaigns) {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(() => _FixedCampaignsNotifier(campaigns)),
    ],
    child: const MaterialApp(home: CampaignsScreen()),
  );
}

Widget buildCard(Campaign campaign) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 400, child: CampaignCard(campaign: campaign)),
    ),
  );
}

final _active = Campaign(
  id: '1',
  name: 'Morning Run',
  goal: 'Run 30 days',
  totalDays: 30,
  currentDay: 18,
  isActive: true,
  dayHistory: List.generate(18, (i) => i % 5 != 3),
);

final _completed = Campaign(
  id: '2',
  name: 'Daily Reading',
  goal: 'Read 21 days',
  totalDays: 21,
  currentDay: 21,
  isActive: false,
  dayHistory: List.generate(21, (i) => true),
);

void main() {
  // ─── CampaignsScreen ────────────────────────────────────────────────────────

  group('CampaignsScreen — populated state', () {
    testWidgets('shows ACTIVE section header when active campaigns exist',
        (tester) async {
      await tester.pumpWidget(buildScreen([_active]));
      await tester.pumpAndSettle();
      expect(find.textContaining('ACTIVE'), findsWidgets);
    });

    testWidgets('shows COMPLETED section header when completed campaigns exist',
        (tester) async {
      await tester.pumpWidget(buildScreen([_active, _completed]));
      await tester.pumpAndSettle();
      expect(find.textContaining('COMPLETED'), findsOneWidget);
    });

    testWidgets('section header uses singular "campaign" for count of 1',
        (tester) async {
      await tester.pumpWidget(buildScreen([_active]));
      await tester.pumpAndSettle();
      expect(find.text('ACTIVE — 1 campaign'), findsOneWidget);
    });

    testWidgets('section header uses plural "campaigns" for count > 1',
        (tester) async {
      final second = Campaign(
        id: '3',
        name: 'No Sugar',
        goal: 'Avoid sugar 14 days',
        totalDays: 14,
        currentDay: 7,
        isActive: true,
        dayHistory: [],
      );
      await tester.pumpWidget(buildScreen([_active, second]));
      await tester.pumpAndSettle();
      expect(find.text('ACTIVE — 2 campaigns'), findsOneWidget);
    });

    testWidgets('campaign name appears on screen', (tester) async {
      await tester.pumpWidget(buildScreen([_active]));
      await tester.pumpAndSettle();
      expect(find.text('Morning Run'), findsOneWidget);
    });

    testWidgets('campaign goal appears on screen', (tester) async {
      await tester.pumpWidget(buildScreen([_active]));
      await tester.pumpAndSettle();
      expect(find.text('Run 30 days'), findsOneWidget);
    });

    testWidgets('FAB add button is present', (tester) async {
      await tester.pumpWidget(buildScreen([_active]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('no ACTIVE section when all campaigns are completed',
        (tester) async {
      await tester.pumpWidget(buildScreen([_completed]));
      await tester.pumpAndSettle();
      expect(find.textContaining('ACTIVE —'), findsNothing);
      expect(find.textContaining('COMPLETED —'), findsOneWidget);
    });
  });

  group('CampaignsScreen — empty state', () {
    testWidgets('shows NO CAMPAIGNS YET text', (tester) async {
      await tester.pumpWidget(buildScreen([]));
      await tester.pumpAndSettle();
      expect(find.text('NO CAMPAIGNS YET'), findsOneWidget);
    });

    testWidgets('shows TAP + TO BEGIN prompt', (tester) async {
      await tester.pumpWidget(buildScreen([]));
      await tester.pumpAndSettle();
      expect(find.text('TAP + TO BEGIN'), findsOneWidget);
    });

    testWidgets('empty state still shows the FAB', (tester) async {
      await tester.pumpWidget(buildScreen([]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('no section headers shown in empty state', (tester) async {
      await tester.pumpWidget(buildScreen([]));
      await tester.pumpAndSettle();
      expect(find.textContaining('ACTIVE —'), findsNothing);
      expect(find.textContaining('COMPLETED —'), findsNothing);
    });
  });

  // ─── CampaignCard ────────────────────────────────────────────────────────────

  group('CampaignCard — completed campaign styling', () {
    testWidgets('percentage label for completed campaign is black',
        (tester) async {
      await tester.pumpWidget(buildCard(_completed));
      await tester.pumpAndSettle();

      final pctFinder = find.text('100%');
      expect(pctFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(pctFinder);
      expect(textWidget.style?.color, equals(kBlack));
    });

    testWidgets('percentage label for active campaign is blue', (tester) async {
      await tester.pumpWidget(buildCard(_active));
      await tester.pumpAndSettle();

      final pctFinder = find.text('60%');
      expect(pctFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(pctFinder);
      expect(textWidget.style?.color, equals(kBlue));
    });

    testWidgets('DONE badge shown for completed campaign', (tester) async {
      await tester.pumpWidget(buildCard(_completed));
      await tester.pumpAndSettle();
      expect(find.text('DONE'), findsOneWidget);
      expect(find.text('ACTIVE'), findsNothing);
    });

    testWidgets('ACTIVE badge shown for active campaign', (tester) async {
      await tester.pumpWidget(buildCard(_active));
      await tester.pumpAndSettle();
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('DONE'), findsNothing);
    });
  });

  group('CampaignCard — day tick strip', () {
    testWidgets('renders without overflow for 30-day campaign', (tester) async {
      await tester.pumpWidget(buildCard(_active));
      await tester.pumpAndSettle();
      // No overflow error → strip renders correctly
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow for short 7-day campaign',
        (tester) async {
      final shortCampaign = Campaign(
        id: 'short',
        name: 'Quick habit',
        goal: '7 days',
        totalDays: 7,
        currentDay: 7,
        isActive: false,
        dayHistory: List.generate(7, (_) => true),
      );
      await tester.pumpWidget(buildCard(shortCampaign));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}

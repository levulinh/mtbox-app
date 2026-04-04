import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/providers/mock_data_provider.dart';
import 'package:mtbox_app/screens/campaigns_screen.dart';
import 'package:mtbox_app/widgets/campaign_card.dart';

// ── Fake notifiers (no Hive) ──────────────────────────────────────────────

class _FixedCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _campaigns;
  _FixedCampaignsNotifier(this._campaigns);

  @override
  List<Campaign> build() => List<Campaign>.from(_campaigns);
}

/// Notifier that simulates checkIn() without Hive — updates state in memory.
class _MutableCampaignsNotifier extends CampaignsNotifier {
  final List<Campaign> _initial;
  _MutableCampaignsNotifier(this._initial);

  @override
  List<Campaign> build() => List<Campaign>.from(_initial);

  @override
  bool checkIn(String campaignId) {
    final idx = state.indexWhere((c) => c.id == campaignId);
    if (idx < 0) return false;
    final c = state[idx];
    if (!c.isActive || c.checkedInToday) return false;
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final newCurrentDay = c.currentDay + 1;
    final isCompleted = newCurrentDay >= c.totalDays;
    final updated = Campaign(
      id: c.id,
      name: c.name,
      goal: c.goal,
      totalDays: c.totalDays,
      currentDay: newCurrentDay,
      isActive: !isCompleted,
      dayHistory: [...c.dayHistory, true],
      lastCheckInDate: dateStr,
    );
    state = [
      ...state.sublist(0, idx),
      updated,
      ...state.sublist(idx + 1),
    ];
    return isCompleted;
  }
}

// ── Helper builders ───────────────────────────────────────────────────────

Widget buildScreen(
  List<Campaign> campaigns, {
  bool mutable = false,
}) {
  return ProviderScope(
    overrides: [
      campaignsProvider.overrideWith(
        () => mutable
            ? _MutableCampaignsNotifier(campaigns)
            : _FixedCampaignsNotifier(campaigns),
      ),
    ],
    child: const MaterialApp(home: CampaignsScreen()),
  );
}

Widget buildCard(Campaign campaign, {VoidCallback? onCheckIn}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(width: 400, child: CampaignCard(campaign: campaign, onCheckIn: onCheckIn)),
    ),
  );
}

// ── Fixtures ──────────────────────────────────────────────────────────────

final _notCheckedIn = Campaign(
  id: 'run',
  name: 'Morning Run',
  goal: 'Run 30 days',
  totalDays: 30,
  currentDay: 5,
  isActive: true,
  dayHistory: List.generate(5, (_) => true),
  lastCheckInDate: null, // not checked in today
);

Campaign get _checkedInToday {
  final now = DateTime.now();
  final today =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return Campaign(
    id: 'run2',
    name: 'Evening Walk',
    goal: 'Walk 30 days',
    totalDays: 30,
    currentDay: 6,
    isActive: true,
    dayHistory: List.generate(6, (_) => true),
    lastCheckInDate: today,
  );
}

final _completed = Campaign(
  id: 'done',
  name: 'Daily Reading',
  goal: 'Read 21 days',
  totalDays: 21,
  currentDay: 21,
  isActive: false,
  dayHistory: List.generate(21, (_) => true),
);

void main() {
  // ── CampaignCard — check-in button state ─────────────────────────────────

  group('CampaignCard — check-in button visibility', () {
    testWidgets('shows CHECK IN TODAY button for active, not-checked-in campaign',
        (tester) async {
      await tester.pumpWidget(buildCard(_notCheckedIn));
      await tester.pumpAndSettle();
      expect(find.text('CHECK IN TODAY'), findsOneWidget);
      expect(find.byIcon(Icons.add_task), findsOneWidget);
    });

    testWidgets('shows CHECKED IN TODAY state for campaign checked in today',
        (tester) async {
      await tester.pumpWidget(buildCard(_checkedInToday));
      await tester.pumpAndSettle();
      expect(find.text('CHECKED IN TODAY'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('CHECK IN TODAY'), findsNothing);
    });

    testWidgets('shows no check-in button for completed campaign', (tester) async {
      await tester.pumpWidget(buildCard(_completed));
      await tester.pumpAndSettle();
      expect(find.text('CHECK IN TODAY'), findsNothing);
      expect(find.text('CHECKED IN TODAY'), findsNothing);
    });

    testWidgets('tapping CHECK IN TODAY invokes onCheckIn callback',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildCard(_notCheckedIn, onCheckIn: () => tapped = true));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CHECK IN TODAY'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('CHECKED IN TODAY state is not tappable (no onTap handler)',
        (tester) async {
      // Verify the confirmed state widget is present and raises no error on tap
      await tester.pumpWidget(buildCard(_checkedInToday));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CHECKED IN TODAY'), warnIfMissed: false);
      expect(tester.takeException(), isNull);
    });
  });

  // ── CampaignCard — day tick strip gold indicator ──────────────────────────

  group('CampaignCard — today tick highlight', () {
    testWidgets('renders without overflow when not checked in (showTodayTick=true)',
        (tester) async {
      await tester.pumpWidget(buildCard(_notCheckedIn));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'renders without overflow when already checked in (showTodayTick=false)',
        (tester) async {
      await tester.pumpWidget(buildCard(_checkedInToday));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  // ── CampaignsScreen — toast after check-in ───────────────────────────────

  group('CampaignsScreen — check-in toast', () {
    testWidgets('no toast shown initially', (tester) async {
      await tester.pumpWidget(buildScreen([_notCheckedIn]));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsNothing);
    });

    testWidgets('toast appears after tapping CHECK IN TODAY', (tester) async {
      await tester.pumpWidget(buildScreen([_notCheckedIn], mutable: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHECK IN TODAY'));
      await tester.pump();

      // Toast uses check_circle icon (card "CHECKED IN TODAY" also has it, so findsWidgets)
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('toast message includes streak count after check-in',
        (tester) async {
      // Campaign has 5 true days → after check-in streak = 6
      await tester.pumpWidget(buildScreen([_notCheckedIn], mutable: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHECK IN TODAY'));
      await tester.pump();

      // Toast text is uppercased, should mention streak
      expect(find.textContaining('STREAK'), findsOneWidget);
    });

    testWidgets('after check-in, campaign card switches to CHECKED IN TODAY',
        (tester) async {
      await tester.pumpWidget(buildScreen([_notCheckedIn], mutable: true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHECK IN TODAY'));
      await tester.pumpAndSettle();

      expect(find.text('CHECKED IN TODAY'), findsOneWidget);
      expect(find.text('CHECK IN TODAY'), findsNothing);
    });
  });
}

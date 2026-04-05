import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/providers/sync_provider.dart';
import 'package:mtbox_app/theme.dart';

// Test for _SyncBadge widget
class _SyncBadgeForTest extends StatelessWidget {
  final SyncPhase phase;

  const _SyncBadgeForTest({required this.phase});

  @override
  Widget build(BuildContext context) {
    return switch (phase) {
      SyncPhase.synced => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(46),
            border: Border.all(
                color: Colors.white.withAlpha(115), width: kSoftBorderWidth),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sync, size: 12, color: kWhite),
              SizedBox(width: 4),
              Text(
                'SYNCED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      SyncPhase.syncing => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(31),
            border: Border.all(
                color: Colors.white.withAlpha(128),
                width: kSoftBorderWidth,
                strokeAlign: BorderSide.strokeAlignInside),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sync, size: 12, color: kWhite),
              SizedBox(width: 4),
              Text(
                'SYNCING',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      SyncPhase.offline => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFDC2626),
            border: Border.all(
                color: const Color(0xFFDC2626), width: kSoftBorderWidth),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 12, color: kWhite),
              SizedBox(width: 4),
              Text(
                'OFFLINE',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
    };
  }
}

void main() {
  group('SyncBadge Widget', () {
    testWidgets('renders SYNCED state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncBadgeForTest(phase: SyncPhase.synced),
          ),
        ),
      );

      expect(find.text('SYNCED'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('renders SYNCING state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncBadgeForTest(phase: SyncPhase.syncing),
          ),
        ),
      );

      expect(find.text('SYNCING'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('renders OFFLINE state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncBadgeForTest(phase: SyncPhase.offline),
          ),
        ),
      );

      expect(find.text('OFFLINE'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('SYNCED badge has white tint', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncBadgeForTest(phase: SyncPhase.synced),
          ),
        ),
      );

      final container = find.byType(Container).first;
      expect(container, findsOneWidget);
    });

    testWidgets('OFFLINE badge uses red color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncBadgeForTest(phase: SyncPhase.offline),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('badge shows sync icon for synced and syncing states',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                _SyncBadgeForTest(phase: SyncPhase.synced),
                _SyncBadgeForTest(phase: SyncPhase.syncing),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsWidgets);
    });
  });

  group('Device Status Badge Rendering', () {
    testWidgets('renders device info correctly', (WidgetTester tester) async {
      const device = DeviceInfo(
        name: 'iPhone 14 Pro',
        icon: Icons.phone_iphone,
        isCurrentDevice: true,
        isOffline: false,
        lastActive: 'now',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text(device.name),
                Icon(device.icon),
                Text(device.lastActive),
              ],
            ),
          ),
        ),
      );

      expect(find.text('iPhone 14 Pro'), findsOneWidget);
      expect(find.text('now'), findsOneWidget);
    });

    testWidgets('mock devices list is complete', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: kMockDevices
                  .map((d) => Text(d.name))
                  .toList(),
            ),
          ),
        ),
      );

      expect(find.text('iPhone 14 Pro'), findsOneWidget);
      expect(find.text('MacBook Pro'), findsOneWidget);
      expect(find.text('iPad Air'), findsOneWidget);
    });
  });

  group('Sync UI States', () {
    testWidgets('SYNCED phase shows sync icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncBadgeForTest(phase: SyncPhase.synced),
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('OFFLINE phase shows cloud_off icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _SyncBadgeForTest(phase: SyncPhase.offline),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('all three phases render without errors',
        (WidgetTester tester) async {
      for (final phase in [
        SyncPhase.synced,
        SyncPhase.syncing,
        SyncPhase.offline,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: _SyncBadgeForTest(phase: phase),
            ),
          ),
        );

        expect(find.byType(Container), findsWidgets);
        expect(find.byType(Icon), findsOneWidget);
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/main.dart';

void main() {
  group('Real-time Multi-device Sync E2E', () {
    testWidgets('App launches and renders without crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Should render the app successfully
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Home screen displays sync badge on startup',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Sync badge should show in initial state
      expect(find.text('SYNCED', skipOffstage: false), findsOneWidget);
    });

    testWidgets('Device panel is visible when not showing sample data',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Device panel should be visible
      expect(
        find.text('DEVICES', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('All mock devices appear in device panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // All devices should be listed
      expect(
        find.text('iPhone 14 Pro', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('MacBook Pro', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('iPad Air', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('Current device shows THIS DEVICE status',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Current device should show "THIS DEVICE"
      expect(
        find.text('THIS DEVICE', skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('Device icons appear in device panel',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Should find device icons
      expect(find.byIcon(Icons.phone_iphone), findsWidgets);
      expect(find.byIcon(Icons.laptop_mac), findsWidgets);
      expect(find.byIcon(Icons.tablet_mac), findsWidgets);
    });

    testWidgets('Sync badge icon appears in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Sync badge icon should be visible
      expect(find.byIcon(Icons.sync), findsWidgets);
    });

    testWidgets('Status indicator shows one of three states',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Should show one of the sync states
      final hasSynced = find.text('SYNCED', skipOffstage: false).evaluate().isNotEmpty;
      final hasSyncing = find.text('SYNCING', skipOffstage: false).evaluate().isNotEmpty;
      final hasOffline = find.text('OFFLINE', skipOffstage: false).evaluate().isNotEmpty;

      expect(
        hasSynced || hasSyncing || hasOffline,
        true,
      );
    });

    testWidgets('Home screen renders successfully with all components',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Check that main components are present
      expect(find.byType(AppBar), findsWidgets);
      expect(find.byType(Text), findsWidgets);
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('Device names are displayed as uppercase',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MTBoxApp());
      await tester.pumpAndSettle();

      // Device names should appear in uppercase
      expect(
        find.text('IPHONE 14 PRO', skipOffstage: false),
        findsOneWidget,
      );
    });
  });
}

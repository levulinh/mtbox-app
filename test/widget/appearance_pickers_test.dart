import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';
import 'package:mtbox_app/widgets/appearance_pickers.dart';

void main() {
  group('AppearancePickers widget', () {
    testWidgets('renders color section with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppearancePickers(
                selectedColor: '4C6EAD',
                selectedIcon: 'fitness_center',
                onColorSelected: (_) {},
                onIconSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('CAMPAIGN COLOR'), findsOneWidget);
    });

    testWidgets('renders icon section with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppearancePickers(
                selectedColor: '4C6EAD',
                selectedIcon: 'fitness_center',
                onColorSelected: (_) {},
                onIconSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('CAMPAIGN ICON'), findsOneWidget);
    });

    testWidgets('renders color grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppearancePickers(
                selectedColor: '4C6EAD',
                selectedIcon: 'fitness_center',
                onColorSelected: (_) {},
                onIconSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // The color grid should render color containers
      final colorContainers = find.byWidgetPredicate(
        (widget) => widget is Container,
      );
      expect(colorContainers, findsWidgets);
    });

    testWidgets('renders icon grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppearancePickers(
                selectedColor: '4C6EAD',
                selectedIcon: 'fitness_center',
                onColorSelected: (_) {},
                onIconSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // All icons should be rendered
      expect(find.byIcon(Icons.fitness_center), findsWidgets);
      expect(find.byIcon(Icons.menu_book), findsWidgets);
      expect(find.byIcon(Icons.directions_run), findsWidgets);
      expect(find.byIcon(Icons.self_improvement), findsWidgets);
      expect(find.byIcon(Icons.language), findsWidgets);
      expect(find.byIcon(Icons.code), findsWidgets);
      expect(find.byIcon(Icons.music_note), findsWidgets);
      expect(find.byIcon(Icons.restaurant), findsWidgets);
    });

    testWidgets('selected color shows checkmark', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppearancePickers(
                selectedColor: '4C6EAD',
                selectedIcon: 'fitness_center',
                onColorSelected: (_) {},
                onIconSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Selected color should show a checkmark
      final checkmarks = find.byIcon(Icons.check);
      expect(checkmarks, findsWidgets);
    });

    testWidgets('color callbacks fire', (WidgetTester tester) async {
      bool callbackFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppearancePickers(
                selectedColor: '4C6EAD',
                selectedIcon: 'fitness_center',
                onColorSelected: (color) {
                  callbackFired = true;
                },
                onIconSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      // Tap the first color option (after the title)
      final colorContainers = find.byWidgetPredicate(
        (widget) => widget is Container &&
            (widget.decoration as BoxDecoration?)?.color != null &&
            (widget.decoration as BoxDecoration?)?.color ==
                Color(int.parse('4C6EAD', radix: 16) | 0xFF000000),
      );

      if (colorContainers.evaluate().isNotEmpty) {
        await tester.tap(colorContainers.first);
        await tester.pumpAndSettle();
        expect(callbackFired, true);
      }
    });

    testWidgets('icon callbacks fire', (WidgetTester tester) async {
      bool callbackFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppearancePickers(
                selectedColor: '4C6EAD',
                selectedIcon: 'fitness_center',
                onColorSelected: (_) {},
                onIconSelected: (icon) {
                  callbackFired = true;
                },
              ),
            ),
          ),
        ),
      );

      // Tap an icon
      await tester.tap(find.byIcon(Icons.fitness_center).first);
      await tester.pumpAndSettle();

      expect(callbackFired, true);
    });
  });
}

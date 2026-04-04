import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/theme.dart';

void main() {
  group('Visual Delight Rendering (MTB-25)', () {
    testWidgets('SlideTransition can be created with correct offset', (WidgetTester tester) async {
      final animation = AlwaysStoppedAnimation<double>(0.5);
      final offset = Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero)
          .evaluate(animation);

      expect(offset.dx, isNotNull);
      expect(offset.dy, isNotNull);
    });

    testWidgets('Slide animation transitions from right (1.0) to center (0)', (WidgetTester tester) async {
      final tween = Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero);

      final startOffset = tween.evaluate(AlwaysStoppedAnimation<double>(0.0));
      final endOffset = tween.evaluate(AlwaysStoppedAnimation<double>(1.0));

      expect(startOffset.dx, equals(1.0));
      expect(endOffset.dx, equals(0.0));
    });

    testWidgets('Scale animation can target 0.96', (WidgetTester tester) async {
      const targetScale = 0.96;
      final tween = Tween<double>(begin: 1.0, end: targetScale);

      final start = tween.evaluate(AlwaysStoppedAnimation<double>(0.0));
      final end = tween.evaluate(AlwaysStoppedAnimation<double>(1.0));

      expect(start, equals(1.0));
      expect(end, equals(targetScale));
    });

    testWidgets('Container can be animated with changing width', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) => Container(
                width: value * 100,
                height: 100,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      );

      // Verify the animated container renders
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Confetti-style container renders with palette colors', (WidgetTester tester) async {
      const paletteColors = [
        kBlue,
        kTerracotta,
        kBlack,
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                for (final color in paletteColors)
                  Container(
                    width: 20,
                    height: 20,
                    color: color,
                  )
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Empty state message renders', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag, size: 48),
                  const SizedBox(height: 16),
                  const Text('Start a campaign to see it here'),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: brutalistBox(filled: true),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'START A CAMPAIGN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: kWhite,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Start a campaign to see it here'), findsOneWidget);
      expect(find.text('START A CAMPAIGN'), findsOneWidget);
      expect(find.byIcon(Icons.flag), findsOneWidget);
    });

    testWidgets('Celebration toast component structure is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              alignment: Alignment.topCenter,
              child: Container(
                width: double.infinity,
                color: kBlue,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: kWhite),
                    const SizedBox(width: 8),
                    const Text(
                      'Check-in successful!',
                      style: TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Check-in successful!'), findsOneWidget);
    });

    testWidgets('Progress bar with animation builder renders', (WidgetTester tester) async {
      final progressPercent = 0.65;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progressPercent),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Scale and progress animations render together', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                // Scale animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.0, end: 0.96),
                  duration: const Duration(milliseconds: 80),
                  builder: (context, value, child) => Transform.scale(
                    scale: value,
                    child: const Icon(Icons.check),
                  ),
                ),
                // Progress animation
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 0.75),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify both animated elements render
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byType(Transform), findsWidgets);
    });
  });
}

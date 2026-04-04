import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/theme.dart';

void main() {
  group('Theme Refinement Rendering (MTB-24)', () {
    testWidgets('brutalistBox decoration renders with soft shadow', (WidgetTester tester) async {
      final decoration = brutalistBox();

      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow![0].color, kSoftShadowColor);
      expect(decoration.boxShadow![0].color, isNot(kBlack));
      // Verify shadow is more transparent than original
      expect(decoration.boxShadow![0].color.alpha, lessThan(255));
    });

    testWidgets('brutalistBox decoration renders with soft border', (WidgetTester tester) async {
      final decoration = brutalistBox();
      final border = decoration.border as Border;

      expect(border.left.color, kSoftBorderColor);
      expect(border.left.color, isNot(kBlack));
      expect(border.left.width, kSoftBorderWidth);
      expect(border.left.width, lessThan(kBorderWidth));
    });

    testWidgets('Container with brutalistBox renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 200,
              height: 200,
              decoration: brutalistBox(),
              child: const Center(child: Text('Refined Shadows')),
            ),
          ),
          theme: kBrutalistTheme,
        ),
      );

      expect(find.text('Refined Shadows'), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('brutalistBox with filled=true has blue background', (WidgetTester tester) async {
      final decoration = brutalistBox(filled: true);
      expect(decoration.color, kBlue);
    });

    testWidgets('brutalistBox with custom color works', (WidgetTester tester) async {
      const customColor = Color(0xFFDEADBE);
      final decoration = brutalistBox(color: customColor);
      expect(decoration.color, customColor);
    });

    testWidgets('Default brutalistBox has white background', (WidgetTester tester) async {
      final decoration = brutalistBox();
      expect(decoration.color, kWhite);
    });

    testWidgets('Shadow offset remains consistent', (WidgetTester tester) async {
      final decoration = brutalistBox();
      expect(
        decoration.boxShadow![0].offset,
        const Offset(kShadowOffset, kShadowOffset),
      );
    });

    testWidgets('Multiple containers with soft shadows render', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: brutalistBox(),
                  child: const Text('Box 1'),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: brutalistBox(),
                  child: const Text('Box 2'),
                ),
              ],
            ),
          ),
          theme: kBrutalistTheme,
        ),
      );

      expect(find.text('Box 1'), findsOneWidget);
      expect(find.text('Box 2'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('Theme constants are correctly defined', (WidgetTester tester) async {
      // Soft shadow color (semi-transparent dark)
      expect(kSoftShadowColor.red, 44);
      expect(kSoftShadowColor.green, 44);
      expect(kSoftShadowColor.blue, 44);
      expect(kSoftShadowColor.alpha, 115); // 0x73 = 115

      // Soft border color (lighter gray)
      expect(kSoftBorderColor.red, 90);
      expect(kSoftBorderColor.green, 90);
      expect(kSoftBorderColor.blue, 90);

      // Soft border width
      expect(kSoftBorderWidth, 1.5);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/theme.dart';

void main() {
  group('Theme Refinement (MTB-24)', () {
    test('Soft shadow color is defined with correct opacity', () {
      expect(kSoftShadowColor, const Color(0x732C2C2C));
      // Check alpha channel (0x73 = 115/255 ≈ 0.45 opacity)
      expect(kSoftShadowColor.alpha, 115);
    });

    test('Soft border color is softer than original', () {
      expect(kSoftBorderColor, const Color(0xFF5A5A5A));
      expect(kSoftBorderColor, isNot(kBlack));
      // kSoftBorderColor should be lighter than kBlack
      expect(kSoftBorderColor.red, greaterThan(kBlack.red));
    });

    test('Soft border width is thinner than original', () {
      expect(kSoftBorderWidth, 1.5);
      expect(kSoftBorderWidth, lessThan(kBorderWidth));
    });

    test('brutalistBox returns decoration with soft colors', () {
      final decoration = brutalistBox();

      // Verify box shadow uses soft color
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
      expect(decoration.boxShadow![0].color, kSoftShadowColor);
      expect(decoration.boxShadow![0].offset, const Offset(2.0, 2.0));
    });

    test('brutalistBox border uses soft color and width', () {
      final decoration = brutalistBox();

      expect(decoration.border, isNotNull);
      final border = decoration.border as Border;
      expect(border.left.color, kSoftBorderColor);
      expect(border.left.width, kSoftBorderWidth);
    });

    test('brutalistBox with filled=true uses kBlue background', () {
      final decoration = brutalistBox(filled: true);
      expect(decoration.color, kBlue);
    });

    test('brutalistBox with custom color uses that color', () {
      const customColor = Color(0xFFDEADBE);
      final decoration = brutalistBox(color: customColor);
      expect(decoration.color, customColor);
    });

    test('Shadow offset unchanged from original', () {
      final decoration = brutalistBox();
      expect(decoration.boxShadow![0].offset, const Offset(kShadowOffset, kShadowOffset));
    });
  });
}

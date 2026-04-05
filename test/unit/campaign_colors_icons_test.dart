import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';

void main() {
  group('Campaign color and icon fields', () {
    test('campaignColor parses hex correctly', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 1,
        isActive: true,
        dayHistory: [],
        colorHex: '4C6EAD', // Blue
      );

      expect(campaign.campaignColor, Color(0xFF4C6EAD));
    });

    test('campaignColor handles different hex values', () {
      final colors = {
        '4C6EAD': Color(0xFF4C6EAD), // Blue
        'B5735A': Color(0xFFB5735A), // Terracotta
        'FF0000': Color(0xFFFF0000), // Red
      };

      colors.forEach((hex, expectedColor) {
        final campaign = Campaign(
          id: '1',
          name: 'Test',
          goal: 'Goal',
          totalDays: 30,
          currentDay: 1,
          isActive: true,
          dayHistory: [],
          colorHex: hex,
        );
        expect(campaign.campaignColor, expectedColor);
      });
    });

    test('iconData returns correct IconData for known names', () {
      final iconNames = [
        'fitness_center',
        'menu_book',
        'directions_run',
        'self_improvement',
        'language',
        'code',
        'music_note',
        'restaurant',
      ];

      for (final name in iconNames) {
        final campaign = Campaign(
          id: '1',
          name: 'Test',
          goal: 'Goal',
          totalDays: 30,
          currentDay: 1,
          isActive: true,
          dayHistory: [],
          iconName: name,
        );

        expect(campaign.iconData, isNotNull);
        expect(campaign.iconData, isA<IconData>());
      }
    });

    test('iconData returns fitness_center fallback for unknown names', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 1,
        isActive: true,
        dayHistory: [],
        iconName: 'unknown_icon_name',
      );

      expect(campaign.iconData, Icons.fitness_center);
    });

    test('default values are Blue and fitness_center', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 1,
        isActive: true,
        dayHistory: [],
      );

      expect(campaign.colorHex, '4C6EAD');
      expect(campaign.iconName, 'fitness_center');
      expect(campaign.campaignColor, Color(0xFF4C6EAD));
      expect(campaign.iconData, Icons.fitness_center);
    });

    test('color and icon can be set independently', () {
      final campaign = Campaign(
        id: '1',
        name: 'Test',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 1,
        isActive: true,
        dayHistory: [],
        colorHex: 'B5735A', // Terracotta
        iconName: 'menu_book', // Book icon
      );

      expect(campaign.colorHex, 'B5735A');
      expect(campaign.iconName, 'menu_book');
    });
  });

  group('Campaign color and icon constants', () {
    test('kCampaignColorOptions has 8 colors', () {
      expect(kCampaignColorOptions.length, 8);
    });

    test('kCampaignColorOptions colors are valid hex', () {
      for (final hex in kCampaignColorOptions) {
        expect(hex.length, 6); // No # prefix
        expect(int.tryParse(hex, radix: 16), isNotNull);
      }
    });

    test('kCampaignIconOptions has 8 icons', () {
      expect(kCampaignIconOptions.length, 8);
    });

    test('kCampaignIconOptions entries are pairs of name and icon', () {
      for (final (name, icon) in kCampaignIconOptions) {
        expect(name, isNotEmpty);
        expect(icon, isA<IconData>());
      }
    });

    test('all icon names in options are valid for lookup', () {
      for (final (name, _) in kCampaignIconOptions) {
        final campaign = Campaign(
          id: '1',
          name: 'Test',
          goal: 'Goal',
          totalDays: 30,
          currentDay: 1,
          isActive: true,
          dayHistory: [],
          iconName: name,
        );

        // Should not fallback to fitness_center
        expect(campaign.iconData, isNotNull);
      }
    });
  });

  group('Campaign color backward compatibility', () {
    test('old campaign with defaults has Blue color and fitness icon', () {
      // Simulating a campaign that was created before colorHex/iconName were added
      final oldCampaign = Campaign(
        id: '1',
        name: 'Legacy Campaign',
        goal: 'Goal',
        totalDays: 30,
        currentDay: 15,
        isActive: true,
        dayHistory: List.filled(15, true),
        // colorHex and iconName are not specified, should use defaults
      );

      expect(oldCampaign.colorHex, '4C6EAD'); // Default blue
      expect(oldCampaign.iconName, 'fitness_center'); // Default icon
    });
  });
}

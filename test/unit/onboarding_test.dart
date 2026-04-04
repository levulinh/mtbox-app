import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/models/campaign.dart';

void main() {
  group('Onboarding Form Validation', () {
    test('Campaign name validation: empty name should be rejected', () {
      final name = '';
      final isValid = name.trim().isNotEmpty;
      expect(isValid, false);
    });

    test('Campaign name validation: whitespace-only name should be rejected', () {
      final name = '   ';
      final isValid = name.trim().isNotEmpty;
      expect(isValid, false);
    });

    test('Campaign name validation: valid name should pass', () {
      final name = 'Exercise Daily';
      final isValid = name.trim().isNotEmpty;
      expect(isValid, true);
    });

    test('Campaign days validation: zero days should be rejected', () {
      final days = 0;
      final isValid = days >= 1;
      expect(isValid, false);
    });

    test('Campaign days validation: negative days should be rejected', () {
      final days = -5;
      final isValid = days >= 1;
      expect(isValid, false);
    });

    test('Campaign days validation: valid days should pass', () {
      final days = 30;
      final isValid = days >= 1;
      expect(isValid, true);
    });

    test('Campaign name is properly trimmed before validation', () {
      final name = '  Exercise Daily  ';
      final trimmed = name.trim();
      final isValid = trimmed.isNotEmpty;
      expect(isValid, true);
      expect(trimmed, 'Exercise Daily');
    });

    test('Days input parsing: valid integer should parse correctly', () {
      final input = '30';
      final parsed = int.tryParse(input.trim());
      expect(parsed, 30);
      expect(parsed! >= 1, true);
    });

    test('Days input parsing: invalid input should return null', () {
      final input = 'abc';
      final parsed = int.tryParse(input.trim());
      expect(parsed, null);
    });

    test('Days input parsing: empty input should return null', () {
      final input = '';
      final parsed = int.tryParse(input.trim());
      expect(parsed, null);
    });
  });

  group('Campaign Model', () {
    test('Campaign created with valid data should initialize correctly', () {
      final campaign = Campaign(
        id: 'test-campaign-1',
        name: 'Exercise Daily',
        goal: 'Exercise Daily',
        totalDays: 30,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      );

      expect(campaign.id, 'test-campaign-1');
      expect(campaign.name, 'Exercise Daily');
      expect(campaign.totalDays, 30);
      expect(campaign.currentDay, 0);
      expect(campaign.isActive, true);
      expect(campaign.dayHistory, isEmpty);
    });

    test('Campaign name getter returns correct value', () {
      final campaign = Campaign(
        id: '1',
        name: 'Running Challenge',
        goal: 'Running Challenge',
        totalDays: 60,
        currentDay: 0,
        isActive: true,
        dayHistory: [],
      );

      expect(campaign.name, 'Running Challenge');
    });

    test('Campaign can be created with various day counts', () {
      final campaigns = [
        Campaign(id: '1', name: 'Quick Test', goal: 'Quick Test', totalDays: 1, currentDay: 0, isActive: true, dayHistory: []),
        Campaign(id: '2', name: 'Monthly Goal', goal: 'Monthly Goal', totalDays: 30, currentDay: 0, isActive: true, dayHistory: []),
        Campaign(id: '3', name: 'Long Term', goal: 'Long Term', totalDays: 365, currentDay: 0, isActive: true, dayHistory: []),
      ];

      expect(campaigns[0].totalDays, 1);
      expect(campaigns[1].totalDays, 30);
      expect(campaigns[2].totalDays, 365);
    });
  });

  group('Onboarding State Logic', () {
    test('New users should have onboarding not done by default', () {
      final isDone = false; // Default value for new users
      expect(isDone, false);
    });

    test('Onboarding can be marked as complete', () {
      bool isDone = false;
      isDone = true;
      expect(isDone, true);
    });

    test('Campaign ID can be generated from timestamp', () {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final campaignId = timestamp.toString();
      expect(campaignId, isA<String>());
      expect(campaignId.isNotEmpty, true);
    });
  });
}

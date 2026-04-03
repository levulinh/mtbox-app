# Testing Conventions

## How to Run
```bash
export PATH="/Volumes/ex-ssd/flutter/bin:$PATH"
flutter test test/
flutter test test/unit/my_test.dart  # single file
```

## Structure
- `test/unit/` — Pure Dart unit tests (models, services, providers)
- `test/widget/` — Flutter widget tests (UI components in isolation)

## Unit Tests (test/unit/)
Test models and services without Flutter framework:
```dart
import 'package:test/test.dart';
import 'package:mtbox_app/models/campaign.dart';

void main() {
  group('Campaign', () {
    test('isCompleted returns true when progress reaches goal', () {
      final campaign = Campaign(goal: 30, progress: 30);
      expect(campaign.isCompleted, isTrue);
    });
  });
}
```

## Widget Tests (test/widget/)
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/widgets/campaign_card.dart';

void main() {
  testWidgets('CampaignCard shows progress', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CampaignCard(progress: 0.5)));
    expect(find.text('50%'), findsOneWidget);
  });
}
```

## Coverage Rules
- Every model class: test all computed properties and methods
- Every service: test all public methods with happy path + edge cases
- Every widget: test that it renders expected text/icons given props

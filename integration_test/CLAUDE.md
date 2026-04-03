# E2E Integration Tests

## Setup
Requires iOS Simulator running:
```bash
open -a Simulator
```

## How to Run
```bash
export PATH="/Volumes/ex-ssd/flutter/bin:$PATH"
flutter test integration_test/
```

## Structure
One file per major user flow:
- `integration_test/campaign_creation_test.dart` — creating a campaign
- `integration_test/campaign_tracking_test.dart` — logging progress

## Template
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mtbox_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Campaign Creation', () {
    testWidgets('user can create a new campaign', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('New Campaign'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('campaign_name')), '30-day run');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('30-day run'), findsOneWidget);
    });
  });
}
```

## Rules
- Each test must start fresh (`app.main()` with clean state)
- Use `Key()` on interactive widgets so tests can find them reliably
- `pumpAndSettle()` after every tap/navigation

# E2E Integration Tests

## Devices
E2E tests run on a **physical Android device** (USB connected, USB debugging enabled).
iOS Simulator can be used if available (see setup note below).

## How to Run
```bash
export PATH="/Volumes/ex-ssd/flutter/bin:$PATH"

# List connected devices
flutter devices

# Run on connected Android device (auto-detects if only one connected)
flutter test integration_test/ -d android

# Run on specific device ID
flutter test integration_test/ -d <device-id>
```

## iOS Simulator Setup (when needed)
To avoid filling internal storage, symlink simulator runtimes to the SSD first:
```bash
sudo mv ~/Library/Developer/CoreSimulator /Volumes/ex-ssd/CoreSimulator
ln -s /Volumes/ex-ssd/CoreSimulator ~/Library/Developer/CoreSimulator
```
Then install Xcode from App Store and download only the latest iOS runtime in Xcode → Settings → Platforms.

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
- Each test starts fresh (`app.main()` with clean state)
- Use `Key()` on interactive widgets
- `pumpAndSettle()` after every tap/navigation
- Ensure Android device is connected before QA agent runs

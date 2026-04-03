# E2E Integration Tests

## How It Works
The QA agent starts a headless Android Emulator (AVD: MTBox_QA), runs tests, then stops it. No device needs to be connected.

## How to Run Manually
```bash
export ANDROID_HOME=/Volumes/ex-ssd/android-sdk
export PATH="/Volumes/ex-ssd/flutter/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator/emulator:$PATH"

# Start emulator (AVD is stored at ~/.android/avd/MTBox_QA.avd on internal APFS)
$ANDROID_HOME/emulator/emulator/emulator -avd MTBox_QA -no-window -no-audio -no-boot-anim -no-metrics &

# Wait for boot, then run
adb wait-for-device shell getprop sys.boot_completed
flutter test integration_test/ -d emulator-5554

# Stop when done
adb emu kill
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
- Use `Key()` on all interactive widgets for reliable test targeting
- `pumpAndSettle()` after every tap or navigation
- The QA agent handles emulator lifecycle — no manual setup needed

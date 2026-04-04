import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtbox_app/main.dart';

void main() {
  testWidgets('App shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MTBoxApp(initialLocation: '/')),
    );
    await tester.pumpAndSettle();
    expect(find.text('HEY DREW'), findsOneWidget);
  });
}

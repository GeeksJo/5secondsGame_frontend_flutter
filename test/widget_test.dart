import 'package:flutter_test/flutter_test.dart';

void main() {
  // Integration tests that call GameKit.initialize should tearDown with:
  // `await GameKit.dispose();` (see game_kit package README).
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Placeholder test
    expect(1 + 1, 2);
  });
}

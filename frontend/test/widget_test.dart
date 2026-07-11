import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safenet_ai/main.dart';

void main() {
  testWidgets('App renders login screen title smoke test', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: SafeNetApp(),
      ),
    );

    // Let any introductory animations/router redirects settle
    await tester.pumpAndSettle();

    // Verify that the login screen loads with the brand name title
    expect(find.text('SafeNet AI'), findsWidgets);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:popper/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp("test-device"));
    await tester.pump();
    // Just verify the app renders something
    expect(find.byType(MyApp), findsOneWidget);
  });
}
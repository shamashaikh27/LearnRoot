import 'package:flutter_test/flutter_test.dart';

import 'package:learnroot_71/main.dart';

void main() {
  testWidgets('LearnRoot app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const LearnRootApp());

    await tester.pumpAndSettle();

    expect(find.text('LearnRoot'), findsOneWidget);
  });
}
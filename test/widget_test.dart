import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fundapp_mobile/main.dart';

void main() {
  testWidgets('FundAPP root renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FundAppRoot(),
      ),
    );

    await tester.pump();
    expect(find.byType(FundAppRoot), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'package:showcase/components/my_widget.dart';
import '../helpers/golden_boundary.dart';

void main() {
  testWidgets('MyWidget golden', (WidgetTester tester) async {
    await tester.pumpWidget(GoldenBoundary(
      child: MyWidget(),
    ));

    await expectLater(
      find.byType(MyWidget),
      matchesGoldenFile('golden.png'),
    );
  });
}

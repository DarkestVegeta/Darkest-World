import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/main.dart';

void main() {
  testWidgets('DarkestWorld opens the Galaxy preview', (tester) async {
    await tester.pumpWidget(const DarkestWorldApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('DARKESTWORLD'), findsOneWidget);
    expect(find.text('GALAXY'), findsOneWidget);
  });
}

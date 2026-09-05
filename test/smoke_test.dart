import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/main.dart';

void main() {
  testWidgets('DarkestWorld shows the basic configuration state', (tester) async {
    await tester.pumpWidget(const DarkestWorldApp(configurationMissing: true));

    expect(find.text('DarkestWorld configuration is missing.'), findsOneWidget);
  });
}

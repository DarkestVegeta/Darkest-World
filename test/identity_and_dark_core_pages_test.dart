import 'package:darkest_world/screens/dark_core_page.dart';
import 'package:darkest_world/screens/identity_world_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Identity World construction layer renders its live section context', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IdentityWorldPage(
          title: 'Identity World',
          description: 'The identity and personal collection world of DarkestWorld.',
        ),
      ),
    );

    expect(find.text('Identity World'), findsNWidgets(2));
    expect(find.text('Identity'), findsOneWidget);
    expect(find.textContaining('personal collection'), findsOneWidget);
  });

  testWidgets('Dark Core construction layer renders its core context', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DarkCorePage(
          title: 'Dark Core',
          description: 'The core of DarkestVegeta and its world.',
        ),
      ),
    );

    expect(find.text('Dark Core'), findsNWidgets(2));
    expect(find.text('Core'), findsOneWidget);
    expect(find.textContaining('core systems and lore'), findsOneWidget);
  });
}

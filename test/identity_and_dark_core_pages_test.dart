import 'package:darkest_world/screens/dark_core_page.dart';
import 'package:darkest_world/screens/identity_world_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Identity World construction layer renders its live world page', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IdentityWorldPage(
          title: 'Identity World',
          description: 'The identity and personal collection world of DarkestWorld.',
        ),
      ),
    );

    expect(find.text('Identity World'), findsOneWidget);
  });

  testWidgets('Dark Core construction layer renders its core world page', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DarkCorePage(
          title: 'Dark Core',
          description: 'The core of DarkestVegeta and its world.',
        ),
      ),
    );

    expect(find.text('Dark Core'), findsOneWidget);
  });
}

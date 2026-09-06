import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/screens/darkest_vegeta_visual_hub_page.dart';

void main() {
  testWidgets('shows the Visual Hub construction layer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DarkestVegetaVisualHubPage(),
      ),
    );

    expect(find.text('DarkestVegeta Visual Hub'), findsNWidgets(2));
    expect(find.text('Construction layer'), findsOneWidget);
    expect(find.text('Streaming Room'), findsOneWidget);
    expect(find.text('LEFT'), findsOneWidget);
    expect(find.text('CENTER'), findsOneWidget);
    expect(find.text('RIGHT'), findsOneWidget);
    expect(find.text('DarkestVegeta persona / desk area'), findsOneWidget);
    expect(
      find.textContaining('No artwork, database rows, or stored images are created'),
      findsOneWidget,
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/screens/timeline_world_page.dart';

void main() {
  testWidgets('shows the Timeline construction layer without creating data', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TimelineWorldPage(
          title: 'Timeline / Chronology',
          description: 'Chronological navigation across connected content.',
        ),
      ),
    );

    expect(find.text('Timeline / Chronology'), findsOneWidget);
    expect(find.text('Construction layer'), findsOneWidget);
    expect(find.textContaining('Game → Game → Movie → Series → Game'), findsOneWidget);
    expect(find.textContaining('Timeline data is not populated yet.'), findsOneWidget);
  });
}

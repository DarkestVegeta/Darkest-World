import 'package:darkest_world/widgets/falling_star_easter_egg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('warning light lasts 1.4 seconds before meteor launch',
      (tester) async {
    var caught = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FallingStarEasterEgg(
                initialDelay: Duration.zero,
                onCaught: () => caught = true,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(GestureDetector), findsOneWidget);
    expect(caught, isFalse);

    await tester.pump(const Duration(milliseconds: 1399));
    expect(find.byType(GestureDetector), findsOneWidget);
    expect(caught, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('clicking the warning light triggers the catch callback',
      (tester) async {
    var caught = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              FallingStarEasterEgg(
                initialDelay: Duration.zero,
                onCaught: () => caught = true,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    expect(caught, isTrue);
    expect(find.byType(GestureDetector), findsNothing);
  });
}

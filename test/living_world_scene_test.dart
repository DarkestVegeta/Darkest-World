import 'package:darkest_world/widgets/living_world_scene.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('living world scene mounts and keeps its child visible',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LivingWorldScene(
            child: Center(child: Text('Darkest-World')),
          ),
        ),
      ),
    );

    expect(find.text('Darkest-World'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Darkest-World'), findsOneWidget);
  });
}

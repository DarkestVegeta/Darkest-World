import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/widgets/darkest_world_universe.dart';

void main() {
  const worlds = <GalaxyWorld>[
    GalaxyWorld(kind: GalaxyWorldKind.game, title: 'Game World', description: 'Game systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.cinema, title: 'Cinema World', description: 'Cinema systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.creation, title: 'Creation', description: 'Creation systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.music, title: 'Music World', description: 'Music systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.family, title: 'Family', description: 'Family systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.archive, title: 'Archive', description: 'Archive systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.identity, title: 'Identity', description: 'Identity systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.vegeta, title: 'Vegeta', description: 'Core systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.comingSoon, title: 'Coming Soon', description: 'Future systems.'),
  ];

  SemanticsFinder worldSemantics(String title) =>
      find.bySemanticsLabel(RegExp('^${RegExp.escape(title)}'));

  Future<void> pumpGalaxy(WidgetTester tester, {ValueChanged<GalaxyWorld>? onWorldTap}) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DarkestWorldUniverse(worlds: worlds, onWorldTap: onWorldTap),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 80));
  }

  testWidgets('Galaxy renders all world nodes and exposes semantics', (tester) async {
    await pumpGalaxy(tester);
    expect(find.text('DARKESTWORLD'), findsOneWidget);
    for (final world in worlds) {
      expect(worldSemantics(world.title), findsOneWidget);
    }
  });

  testWidgets('Selecting a world opens its command panel and VISIT callback', (tester) async {
    GalaxyWorld? visited;
    await pumpGalaxy(tester, onWorldTap: (world) => visited = world);
    await tester.tap(worldSemantics('Game World'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('GAME WORLD'), findsOneWidget);
    expect(find.textContaining('VISIT'), findsOneWidget);
    await tester.tap(find.textContaining('VISIT'));
    await tester.pump();
    expect(visited?.kind, GalaxyWorldKind.game);
  });

  testWidgets('Keyboard digit navigation targets the matching world', (tester) async {
    await pumpGalaxy(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit2);
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('CINEMA WORLD'), findsOneWidget);
    expect(find.text('TARGET LOCK'), findsOneWidget);
  });

  testWidgets('All nine digit shortcuts target the correct galaxy world', (tester) async {
    await pumpGalaxy(tester);
    const keys = <LogicalKeyboardKey>[
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
    ];
    for (var i = 0; i < keys.length; i++) {
      await tester.sendKeyEvent(keys[i]);
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('TARGET LOCK'), findsOneWidget);
      expect(find.text(worlds[i].title.toUpperCase()), findsOneWidget);
    }
  });

  testWidgets('Previous and next controls cycle through the world chain', (tester) async {
    await pumpGalaxy(tester);
    await tester.tap(worldSemantics('Game World'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('CURRENT'), findsOneWidget);
    expect(find.text('PREVIOUS'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    await tester.tap(find.text('NEXT'));
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.text('CINEMA WORLD'), findsOneWidget);
  });

  testWidgets('Keyboard navigation moves backward and forward through gates', (tester) async {
    await pumpGalaxy(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('CINEMA WORLD'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('GAME WORLD'), findsOneWidget);
  });

  testWidgets('Escape clears target lock and Enter visits the selected gate', (tester) async {
    GalaxyWorld? visited;
    await pumpGalaxy(tester, onWorldTap: (world) => visited = world);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit1);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('TARGET LOCK'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(visited?.kind, GalaxyWorldKind.game);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('TARGET LOCK'), findsNothing);
  });

  testWidgets('Galaxy controls are present', (tester) async {
    await pumpGalaxy(tester);
    expect(find.text('MAP'), findsOneWidget);
    expect(find.text('LABELS'), findsOneWidget);
    expect(find.text('DETAIL'), findsOneWidget);
    expect(find.text('SAFE'), findsOneWidget);
    expect(find.text('PAUSE'), findsOneWidget);
    expect(find.text('MOTION'), findsOneWidget);
    expect(find.text('RESET'), findsOneWidget);
  });
}

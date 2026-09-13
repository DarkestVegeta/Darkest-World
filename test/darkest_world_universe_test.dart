import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/widgets/darkest_world_universe.dart';

void main() {
  const worlds = <GalaxyWorld>[
    GalaxyWorld(kind: GalaxyWorldKind.game, title: 'Game World', description: 'Game systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.cinema, title: 'Cinema World', description: 'Cinema systems.'),
    GalaxyWorld(kind: GalaxyWorldKind.creation, title: 'Creation', description: 'Creation systems.'),
  ];

  testWidgets('Galaxy renders without crashing and exposes world nodes', (tester) async {
    GalaxyWorld? visited;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DarkestWorldUniverse(worlds: worlds, onWorldTap: (world) => visited = world),
      ),
    ));

    expect(find.text('DARKESTWORLD'), findsOneWidget);
    expect(find.bySemanticsLabel('Game World'), findsOneWidget);
    expect(find.bySemanticsLabel('Cinema World'), findsOneWidget);
    expect(find.bySemanticsLabel('Creation'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Game World'));
    await tester.pump();
    expect(find.text('GAME WORLD'), findsOneWidget);

    await tester.tap(find.textContaining('VISIT'));
    await tester.pump();
    expect(visited?.kind, GalaxyWorldKind.game);
  });

  testWidgets('Galaxy controls are present', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DarkestWorldUniverse(worlds: worlds),
      ),
    ));

    expect(find.text('MAP'), findsOneWidget);
    expect(find.text('LABELS'), findsOneWidget);
    expect(find.text('DETAIL'), findsOneWidget);
    expect(find.text('SAFE'), findsOneWidget);
    expect(find.text('PAUSE'), findsOneWidget);
    expect(find.text('MOTION'), findsOneWidget);
    expect(find.text('RESET'), findsOneWidget);
  });
}

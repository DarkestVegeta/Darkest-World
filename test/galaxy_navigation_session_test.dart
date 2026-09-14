import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/screens/galaxy_navigation_session.dart';
import 'package:darkest_world/widgets/darkest_world_universe.dart';

void main() {
  final session = GalaxyNavigationSession.instance;

  setUp(() {
    session.selected = null;
    session.visits = 0;
    session.targetLocked = false;
    session.visited.clear();
    session.mapped.clear();
    session.discoveryOrder.clear();
    session.routeHistory.clear();
    session.gateHistory.clear();
    session.historyCursor = -1;
  });

  test('selection builds discovery and route state', () {
    session.select(GalaxyWorldKind.game);
    session.select(GalaxyWorldKind.music);

    expect(session.selected, GalaxyWorldKind.music);
    expect(session.mapped, containsAll(<GalaxyWorldKind>[
      GalaxyWorldKind.game,
      GalaxyWorldKind.music,
    ]));
    expect(session.discoveryOrder, <GalaxyWorldKind>[
      GalaxyWorldKind.game,
      GalaxyWorldKind.music,
    ]);
    expect(session.routeHistory, <GalaxyWorldKind>[
      GalaxyWorldKind.game,
      GalaxyWorldKind.music,
    ]);
  });

  test('mapped and visited remain separate', () {
    session.select(GalaxyWorldKind.game);

    expect(session.isMapped(GalaxyWorldKind.game), isTrue);
    expect(session.isVisited(GalaxyWorldKind.game), isFalse);

    session.visit(GalaxyWorldKind.game);

    expect(session.isMapped(GalaxyWorldKind.game), isTrue);
    expect(session.isVisited(GalaxyWorldKind.game), isTrue);
    expect(session.visits, 1);
    expect(session.lastGate(), GalaxyWorldKind.game);
  });

  test('target lock prevents accidental target changes', () {
    session.select(GalaxyWorldKind.game);
    session.toggleTargetLock();

    session.select(GalaxyWorldKind.music);

    expect(session.selected, GalaxyWorldKind.game);
    expect(session.targetLocked, isTrue);
    expect(session.routeHistory, <GalaxyWorldKind>[GalaxyWorldKind.game]);

    session.unlockTarget();
    session.select(GalaxyWorldKind.music);
    expect(session.selected, GalaxyWorldKind.music);
  });

  test('history moves without inventing a visit', () {
    session.select(GalaxyWorldKind.game);
    session.select(GalaxyWorldKind.music);
    session.select(GalaxyWorldKind.cinema);

    expect(session.previousHistory(), GalaxyWorldKind.music);
    expect(session.selected, GalaxyWorldKind.music);
    expect(session.isVisited(GalaxyWorldKind.music), isFalse);
    expect(session.canGoForward, isTrue);

    expect(session.nextHistory(), GalaxyWorldKind.cinema);
    expect(session.selected, GalaxyWorldKind.cinema);
  });

  test('navigation reset clears route state but preserves discovery state', () {
    session.select(GalaxyWorldKind.game);
    session.visit(GalaxyWorldKind.game);
    session.select(GalaxyWorldKind.music);
    session.toggleTargetLock();

    session.resetNavigation();

    expect(session.selected, isNull);
    expect(session.targetLocked, isFalse);
    expect(session.routeHistory, isEmpty);
    expect(session.gateHistory, isEmpty);
    expect(session.historyCursor, -1);
    expect(session.isMapped(GalaxyWorldKind.game), isTrue);
    expect(session.isMapped(GalaxyWorldKind.music), isTrue);
    expect(session.isVisited(GalaxyWorldKind.game), isTrue);
  });
}

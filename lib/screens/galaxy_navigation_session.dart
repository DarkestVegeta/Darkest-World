import '../widgets/darkest_world_universe.dart';

/// Single navigation state owned by the Galaxy surface.
/// Atlas, Command Center and the renderer observe this same session.
class GalaxyNavigationSession {
  GalaxyWorldKind? selected;
  int visits = 0;
  final visited = <GalaxyWorldKind>{};
  final mapped = <GalaxyWorldKind>{};
  final discoveryOrder = <GalaxyWorldKind>[];
  final routeHistory = <GalaxyWorldKind>[];
  final gateHistory = <GalaxyWorldKind>[];

  void select(GalaxyWorldKind kind) {
    selected = kind;
    mapped.add(kind);
    if (!discoveryOrder.contains(kind)) discoveryOrder.add(kind);
    if (routeHistory.isEmpty || routeHistory.last != kind) {
      routeHistory.add(kind);
      if (routeHistory.length > 32) routeHistory.removeAt(0);
    }
  }

  void visit(GalaxyWorldKind kind) {
    select(kind);
    visited.add(kind);
    visits++;
    gateHistory.remove(kind);
    gateHistory.add(kind);
    if (gateHistory.length > 12) gateHistory.removeAt(0);
  }

  GalaxyWorldKind? historyAt(int index) => index < 0 || index >= routeHistory.length ? null : routeHistory[index];

  GalaxyWorldKind? previousHistory() {
    if (routeHistory.length < 2 || selected == null) return null;
    return historyAt(routeHistory.lastIndexOf(selected!) - 1);
  }

  GalaxyWorldKind? nextHistory() {
    if (routeHistory.length < 2 || selected == null) return null;
    return historyAt(routeHistory.lastIndexOf(selected!) + 1);
  }

  GalaxyWorldKind? lastGate() => gateHistory.isEmpty ? null : gateHistory.last;
}

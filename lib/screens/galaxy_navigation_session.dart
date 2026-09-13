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
  int historyCursor = -1;

  void select(GalaxyWorldKind kind) {
    selected = kind;
    mapped.add(kind);
    if (!discoveryOrder.contains(kind)) discoveryOrder.add(kind);
    if (routeHistory.isEmpty || routeHistory.last != kind) {
      routeHistory.add(kind);
      if (routeHistory.length > 32) routeHistory.removeAt(0);
    }
    historyCursor = routeHistory.isEmpty ? -1 : routeHistory.lastIndexOf(kind);
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

  GalaxyWorldKind? moveHistory(int delta) {
    if (routeHistory.isEmpty) return null;
    if (historyCursor < 0 || historyCursor >= routeHistory.length) historyCursor = routeHistory.length - 1;
    final target = historyCursor + delta;
    if (target < 0 || target >= routeHistory.length) return null;
    historyCursor = target;
    selected = routeHistory[historyCursor];
    mapped.add(selected!);
    if (!discoveryOrder.contains(selected!)) discoveryOrder.add(selected!);
    return selected;
  }

  GalaxyWorldKind? previousHistory() => moveHistory(-1);
  GalaxyWorldKind? nextHistory() => moveHistory(1);

  GalaxyWorldKind? lastGate() => gateHistory.isEmpty ? null : gateHistory.last;
}

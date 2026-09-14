import 'package:flutter/foundation.dart';
import '../widgets/darkest_world_universe.dart';

/// The single navigation state for Galaxy, Atlas and Command Center.
///
/// The session deliberately lives for the lifetime of the application instead
/// of being recreated whenever a page is pushed. This keeps target, discovery,
/// visit and route state coherent while moving between Galaxy surfaces.
class GalaxyNavigationSession extends ChangeNotifier {
  GalaxyNavigationSession._();

  static final GalaxyNavigationSession instance = GalaxyNavigationSession._();

  GalaxyWorldKind? selected;
  int visits = 0;
  bool targetLocked = false;
  final visited = <GalaxyWorldKind>{};
  final mapped = <GalaxyWorldKind>{};
  final discoveryOrder = <GalaxyWorldKind>[];
  final routeHistory = <GalaxyWorldKind>[];
  final gateHistory = <GalaxyWorldKind>[];
  int historyCursor = -1;

  bool isMapped(GalaxyWorldKind kind) => mapped.contains(kind);
  bool isVisited(GalaxyWorldKind kind) => visited.contains(kind);

  int discoveryIndex(GalaxyWorldKind kind) {
    final index = discoveryOrder.indexOf(kind);
    return index < 0 ? 0 : index + 1;
  }

  void select(GalaxyWorldKind kind) {
    if (targetLocked && selected != kind) return;
    selected = kind;
    targetLocked = false;
    mapped.add(kind);
    if (!discoveryOrder.contains(kind)) discoveryOrder.add(kind);

    // Selecting after moving backward creates a new route branch instead of
    // leaving stale forward history behind.
    if (historyCursor >= 0 && historyCursor < routeHistory.length - 1) {
      routeHistory.removeRange(historyCursor + 1, routeHistory.length);
    }
    if (routeHistory.isEmpty || routeHistory.last != kind) {
      routeHistory.add(kind);
      if (routeHistory.length > 32) routeHistory.removeAt(0);
    }
    historyCursor = routeHistory.isEmpty ? -1 : routeHistory.length - 1;
    notifyListeners();
  }

  void toggleTargetLock() {
    if (selected == null) return;
    targetLocked = !targetLocked;
    notifyListeners();
  }

  void unlockTarget() {
    if (!targetLocked) return;
    targetLocked = false;
    notifyListeners();
  }

  void visit(GalaxyWorldKind kind) {
    if (targetLocked && selected != kind) return;
    select(kind);
    visited.add(kind);
    visits++;
    gateHistory.remove(kind);
    gateHistory.add(kind);
    if (gateHistory.length > 12) gateHistory.removeAt(0);
    notifyListeners();
  }

  GalaxyWorldKind? historyAt(int index) =>
      index < 0 || index >= routeHistory.length ? null : routeHistory[index];

  GalaxyWorldKind? moveHistory(int delta) {
    if (routeHistory.isEmpty) return null;
    if (historyCursor < 0 || historyCursor >= routeHistory.length) {
      historyCursor = routeHistory.length - 1;
    }
    final target = historyCursor + delta;
    if (target < 0 || target >= routeHistory.length) return null;
    historyCursor = target;
    selected = routeHistory[historyCursor];
    targetLocked = false;
    mapped.add(selected!);
    if (!discoveryOrder.contains(selected!)) discoveryOrder.add(selected!);
    notifyListeners();
    return selected;
  }

  GalaxyWorldKind? previousHistory() => moveHistory(-1);
  GalaxyWorldKind? nextHistory() => moveHistory(1);

  GalaxyWorldKind? lastGate() => gateHistory.isEmpty ? null : gateHistory.last;

  bool get canGoBack => historyCursor > 0;
  bool get canGoForward =>
      historyCursor >= 0 && historyCursor < routeHistory.length - 1;

  void resetNavigation() {
    selected = null;
    targetLocked = false;
    routeHistory.clear();
    gateHistory.clear();
    historyCursor = -1;
    notifyListeners();
  }
}

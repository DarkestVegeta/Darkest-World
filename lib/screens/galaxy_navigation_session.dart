import 'package:flutter/foundation.dart';
import '../widgets/darkest_world_universe.dart';

enum GalaxyNavigationSurface { galaxy, atlas, commandCenter, world }

/// The single navigation state for Galaxy, Atlas, Command Center and world pages.
class GalaxyNavigationSession extends ChangeNotifier {
  GalaxyNavigationSession._();
  static final GalaxyNavigationSession instance = GalaxyNavigationSession._();

  GalaxyWorldKind? selected;
  GalaxyWorldKind? lastVisited;
  GalaxyNavigationSurface surface = GalaxyNavigationSurface.galaxy;
  int visits = 0;
  int selectionRevision = 0;
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
  void setSurface(GalaxyNavigationSurface next) {
    if (surface == next) return;
    surface = next;
    notifyListeners();
  }
  void select(GalaxyWorldKind kind) {
    if (targetLocked && selected != kind) return;
    final changed = selected != kind;
    selected = kind;
    targetLocked = false;
    mapped.add(kind);
    if (!discoveryOrder.contains(kind)) discoveryOrder.add(kind);
    if (changed) selectionRevision++;
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
  bool visit(GalaxyWorldKind kind) {
    if (targetLocked && selected != kind) return false;
    select(kind);
    visited.add(kind);
    lastVisited = kind;
    visits++;
    gateHistory.remove(kind);
    gateHistory.add(kind);
    if (gateHistory.length > 12) gateHistory.removeAt(0);
    surface = GalaxyNavigationSurface.world;
    notifyListeners();
    return true;
  }
  void returnToGalaxy() {
    surface = GalaxyNavigationSurface.galaxy;
    if (lastVisited != null) {
      selected = lastVisited;
      mapped.add(lastVisited!);
    }
    notifyListeners();
  }
  void openAtlas() { surface = GalaxyNavigationSurface.atlas; notifyListeners(); }
  void openCommandCenter() { surface = GalaxyNavigationSurface.commandCenter; notifyListeners(); }
  GalaxyWorldKind? historyAt(int index) =>
      index < 0 || index >= routeHistory.length ? null : routeHistory[index];
  GalaxyWorldKind? moveHistory(int delta) {
    if (routeHistory.isEmpty) return null;
    if (historyCursor < 0 || historyCursor >= routeHistory.length) historyCursor = routeHistory.length - 1;
    final target = historyCursor + delta;
    if (target < 0 || target >= routeHistory.length) return null;
    historyCursor = target;
    selected = routeHistory[historyCursor];
    targetLocked = false;
    mapped.add(selected!);
    if (!discoveryOrder.contains(selected!)) discoveryOrder.add(selected!);
    selectionRevision++;
    notifyListeners();
    return selected;
  }
  GalaxyWorldKind? previousHistory() => moveHistory(-1);
  GalaxyWorldKind? nextHistory() => moveHistory(1);
  GalaxyWorldKind? lastGate() => gateHistory.isEmpty ? null : gateHistory.last;
  bool get canGoBack => historyCursor > 0;
  bool get canGoForward => historyCursor >= 0 && historyCursor < routeHistory.length - 1;
  void resetNavigation() {
    selected = null;
    lastVisited = null;
    surface = GalaxyNavigationSurface.galaxy;
    targetLocked = false;
    routeHistory.clear();
    gateHistory.clear();
    historyCursor = -1;
    selectionRevision++;
    notifyListeners();
  }
}

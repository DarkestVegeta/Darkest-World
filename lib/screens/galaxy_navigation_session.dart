import 'dart:async';

import 'package:flutter/foundation.dart';
import '../core/galaxy_render_state.dart';

enum GalaxyNavigationSurface { galaxy, atlas, commandCenter, world }

/// The single navigation state for Galaxy, Atlas, Command Center and world pages.
/// Dynamic world values keep this state layer independent from the renderer/model layer.
class GalaxyNavigationSession extends ChangeNotifier {
  GalaxyNavigationSession._();
  static final GalaxyNavigationSession instance = GalaxyNavigationSession._();

  dynamic selected;
  dynamic lastVisited;
  GalaxyNavigationSurface surface = GalaxyNavigationSurface.galaxy;
  int visits = 0;
  int selectionRevision = 0;
  bool targetLocked = false;
  final visited = <dynamic>{};
  final mapped = <dynamic>{};
  final discoveryOrder = <dynamic>[];
  final routeHistory = <dynamic>[];
  final gateHistory = <dynamic>[];
  int historyCursor = -1;

  GalaxyRenderState renderState = GalaxyRenderState.initial(compact: false);
  bool _renderNotificationQueued = false;

  void _notifyRenderListeners() {
    if (_renderNotificationQueued) return;
    _renderNotificationQueued = true;
    scheduleMicrotask(() {
      _renderNotificationQueued = false;
      if (hasListeners) notifyListeners();
    });
  }

  void updateRenderState(GalaxyRenderState next) {
    if (renderState == next) return;
    renderState = next;
    _notifyRenderListeners();
  }

  void resetRenderState({required bool compact}) {
    renderState = GalaxyRenderState.initial(compact: compact);
    _notifyRenderListeners();
  }

  bool isMapped(dynamic kind) => mapped.contains(kind);
  bool isVisited(dynamic kind) => visited.contains(kind);
  int discoveryIndex(dynamic kind) {
    final index = discoveryOrder.indexOf(kind);
    return index < 0 ? 0 : index + 1;
  }
  void setSurface(GalaxyNavigationSurface next) {
    if (surface == next) return;
    surface = next;
    notifyListeners();
  }
  void select(dynamic kind) {
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
  void clearSelection() {
    if (selected == null && !targetLocked) return;
    selected = null;
    targetLocked = false;
    selectionRevision++;
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
  bool visit(dynamic kind) {
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
  dynamic historyAt(int index) => index < 0 || index >= routeHistory.length ? null : routeHistory[index];
  dynamic moveHistory(int delta) {
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
  dynamic previousHistory() => moveHistory(-1);
  dynamic nextHistory() => moveHistory(1);
  dynamic lastGate() => gateHistory.isEmpty ? null : gateHistory.last;
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
    renderState = GalaxyRenderState.initial(compact: renderState.compact);
    notifyListeners();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import '../core/galaxy_render_state.dart';

enum GalaxyNavigationSurface { galaxy, atlas, commandCenter, world }

/// Shared navigation state for Galaxy, browser routes, Atlas and world pages.
/// Renderer state stays independent from route mechanics, while both can observe
/// the same session for consistent discovery and navigation history.
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

  /// Browser navigation mirrors the real Navigator stack through the observer.
  /// Labels are deliberately lightweight so the session never owns Route objects.
  final browserRouteHistory = <String>[];
  int browserHistoryCursor = -1;
  String? currentBrowserRoute;

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

  void openAtlas() {
    surface = GalaxyNavigationSurface.atlas;
    notifyListeners();
  }

  void openCommandCenter() {
    surface = GalaxyNavigationSurface.commandCenter;
    notifyListeners();
  }

  /// Record a real Navigator route in the shared session without storing
  /// framework Route objects. This keeps the session serializable and cheap.
  void recordBrowserRoute(String label) {
    if (label.isEmpty) return;
    if (browserHistoryCursor >= 0 && browserHistoryCursor < browserRouteHistory.length - 1) {
      browserRouteHistory.removeRange(browserHistoryCursor + 1, browserRouteHistory.length);
    }
    if (browserRouteHistory.isEmpty || browserRouteHistory.last != label) {
      browserRouteHistory.add(label);
      if (browserRouteHistory.length > 32) browserRouteHistory.removeAt(0);
    }
    browserHistoryCursor = browserRouteHistory.isEmpty ? -1 : browserRouteHistory.length - 1;
    currentBrowserRoute = label;
    notifyListeners();
  }

  void removeBrowserRoute(String label) {
    browserRouteHistory.remove(label);
    if (browserRouteHistory.isEmpty) {
      browserHistoryCursor = -1;
      currentBrowserRoute = null;
    } else {
      browserHistoryCursor = browserRouteHistory.length - 1;
      currentBrowserRoute = browserRouteHistory.last;
    }
    notifyListeners();
  }

  void replaceBrowserRoute(String label) {
    if (browserRouteHistory.isEmpty) {
      recordBrowserRoute(label);
      return;
    }
    browserRouteHistory[browserRouteHistory.length - 1] = label;
    browserHistoryCursor = browserRouteHistory.length - 1;
    currentBrowserRoute = label;
    notifyListeners();
  }

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
    browserRouteHistory.clear();
    browserHistoryCursor = -1;
    currentBrowserRoute = null;
    historyCursor = -1;
    selectionRevision++;
    renderState = GalaxyRenderState.initial(compact: renderState.compact);
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/darkest_world_navigation_state.dart';
import '../screens/content_detail_page.dart';
import '../screens/galaxy_navigation_session.dart';

/// Keeps directly opened detail routes connected to the shared content state.
/// Route objects never enter GalaxyNavigationSession.
class DarkestWorldContentDetailObserver extends NavigatorObserver {
  final _repository = ContentRepository();
  final _navigation = GalaxyNavigationSession.instance;
  String? _syncingId;

  void _scheduleSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _scheduleSync();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _scheduleSync();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _scheduleSync();

  void _sync() {
    final navigator = this.navigator;
    final root = navigator?.overlay?.context;
    if (root == null) return;

    final detail = _findDetail(root);
    if (detail == null) return;

    final item = detail.item;
    if (_navigation.contentNavigation?.current.id == item.id) return;
    if (_syncingId == item.id) return;

    _syncingId = item.id;
    _load(item);
  }

  ContentDetailPage? _findDetail(Element root) {
    ContentDetailPage? found;

    void visit(Element element) {
      if (found != null) return;
      if (element.widget is ContentDetailPage) {
        found = element.widget as ContentDetailPage;
        return;
      }
      element.visitChildElements(visit);
    }

    visit(root);
    return found;
  }

  Future<void> _load(ContentItem item) async {
    try {
      final results = await Future.wait<Object?>([
        _repository.getTypedFranchiseNavigation(item),
        _repository.getRelatedContentItems(item.id),
      ]);

      final typed = results[0] as TypedFranchiseNavigation?;
      final related = results[1] as List<ContentItem>;

      if (_navigation.contentNavigation?.current.id == item.id) return;

      _navigation.publishContentNavigation(
        DarkestWorldNavigationState(
          previous: typed?.previous,
          current: typed?.current ?? item,
          next: typed?.next,
          related: related,
          source: 'detail',
          entryPoint: 'direct',
        ),
      );
    } catch (_) {
      if (_navigation.contentNavigation?.current.id != item.id) {
        _navigation.publishContentNavigation(
          DarkestWorldNavigationState(
            previous: null,
            current: item,
            next: null,
            related: const [],
            source: 'detail',
            entryPoint: 'direct',
          ),
        );
      }
    } finally {
      if (_syncingId == item.id) _syncingId = null;
    }
  }
}

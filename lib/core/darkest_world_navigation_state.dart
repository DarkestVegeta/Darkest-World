import 'content_models.dart';

/// Lightweight content navigation contract shared by detail/browser surfaces.
/// It contains IDs and titles only; Flutter Route objects never enter this state.
class DarkestWorldNavigationState {
  final ContentItem? previous;
  final ContentItem current;
  final ContentItem? next;
  final List<ContentItem> related;
  final String source;

  const DarkestWorldNavigationState({
    required this.previous,
    required this.current,
    required this.next,
    required this.related,
    required this.source,
  });

  String? get previousId => previous?.id;
  String get currentId => current.id;
  String? get nextId => next?.id;

  List<String> get relatedIds => related.map((item) => item.id).toList(growable: false);
}

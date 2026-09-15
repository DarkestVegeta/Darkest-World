import 'content_models.dart';

/// Lightweight content navigation contract shared by detail/browser surfaces.
/// It contains IDs and titles only; Flutter Route objects never enter this state.
class DarkestWorldNavigationState {
  final ContentItem? previous;
  final ContentItem current;
  final ContentItem? next;
  final List<ContentItem> related;
  final String source;
  final String entryPoint;
  final String? originId;

  const DarkestWorldNavigationState({
    required this.previous,
    required this.current,
    required this.next,
    required this.related,
    required this.source,
    this.entryPoint = 'direct',
    this.originId,
  });

  String? get previousId => previous?.id;
  String get currentId => current.id;
  String? get nextId => next?.id;

  List<String> get relatedIds => related.map((item) => item.id).toList(growable: false);

  DarkestWorldNavigationState copyWith({
    ContentItem? previous,
    ContentItem? current,
    ContentItem? next,
    List<ContentItem>? related,
    String? source,
    String? entryPoint,
    String? originId,
  }) {
    return DarkestWorldNavigationState(
      previous: previous ?? this.previous,
      current: current ?? this.current,
      next: next ?? this.next,
      related: related ?? this.related,
      source: source ?? this.source,
      entryPoint: entryPoint ?? this.entryPoint,
      originId: originId ?? this.originId,
    );
  }
}

import 'darkest_world_navigation_state.dart';

/// Immutable telemetry snapshot shared by archive presentation surfaces.
/// This keeps visual widgets from deriving navigation semantics independently.
class DarkestWorldArchiveTelemetry {
  final String signal;
  final String position;
  final int continuityCount;
  final int relatedCount;
  final bool linkedOrigin;
  final String source;
  final String entryPoint;
  final String currentId;
  final String? previousId;
  final String? nextId;
  final List<String> relatedIds;

  const DarkestWorldArchiveTelemetry({
    required this.signal,
    required this.position,
    required this.continuityCount,
    required this.relatedCount,
    required this.linkedOrigin,
    required this.source,
    required this.entryPoint,
    required this.currentId,
    required this.previousId,
    required this.nextId,
    required this.relatedIds,
  });

  factory DarkestWorldArchiveTelemetry.fromNavigation(
    DarkestWorldNavigationState state,
  ) {
    return DarkestWorldArchiveTelemetry(
      signal: state.archiveSignal,
      position: state.navigationPosition,
      continuityCount: state.continuityCount,
      relatedCount: state.related.length,
      linkedOrigin: state.hasOrigin,
      source: state.source,
      entryPoint: state.entryLabel,
      currentId: state.currentId,
      previousId: state.previousId,
      nextId: state.nextId,
      relatedIds: state.relatedIds,
    );
  }

  bool get hasContinuity => continuityCount > 0;
  bool get hasRelated => relatedCount > 0;
  bool get canGoPrevious => previousId != null && previousId!.isNotEmpty;
  bool get canGoNext => nextId != null && nextId!.isNotEmpty;

  int get relatedVisibleLimit => 5;
  int get compactRelatedVisibleLimit => 3;
  int get visibleRelatedCount => relatedCount.clamp(0, relatedVisibleLimit);
  int get compactVisibleRelatedCount => relatedCount.clamp(0, compactRelatedVisibleLimit);
  int get relatedOverflowCount => (relatedCount - relatedVisibleLimit).clamp(0, relatedCount);
  int get compactRelatedOverflowCount => (relatedCount - compactRelatedVisibleLimit).clamp(0, relatedCount);

  String get chainLabel => '$continuityCount/2';
  String get continuityMode => position == 'SINGLE' ? 'ISOLATED' : 'SEQUENCED';
  String get relatedLabel => relatedCount == 0 ? 'NONE' : '${visibleRelatedCount}${relatedOverflowCount > 0 ? '+' : ''} ACTIVE';
  String get routeLabel => '$source / $entryPoint';
  String get currentLabel => currentId.trim().isEmpty ? 'UNIDENTIFIED' : currentId;
  String get continuityState => '$continuityMode / ${continuityLabel.replaceAll(' / ', ' · ')}';
  String get signalSummary => '$signal · $relatedLabel · $originLabel';

  String get continuityLabel {
    switch (continuityCount) {
      case 2:
        return 'PREVIOUS / CURRENT / NEXT';
      case 1:
        return position == 'START' ? 'CURRENT / NEXT' : 'PREVIOUS / CURRENT';
      default:
        return 'CURRENT ONLY';
    }
  }

  String get originLabel => linkedOrigin ? 'LINKED' : 'LOCAL';
}

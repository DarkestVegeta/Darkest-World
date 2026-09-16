import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/darkest_world_archive_telemetry.dart';
import 'package:darkest_world/core/darkest_world_navigation_state.dart';
import 'package:darkest_world/core/content_models.dart';

ContentItem item(String id, String title) => ContentItem.fromRow({
  'id': id,
  'content_type': 'game',
  'title': title,
  'slug': id,
});

void main() {
  test('full navigation maps into shared archive telemetry', () {
    final previous = item('prev', 'Previous Game');
    final current = item('current', 'Current Game');
    final next = item('next', 'Next Game');
    final related = [
      item('rel-1', 'Related One'),
      item('rel-2', 'Related Two'),
    ];

    const source = 'content_detail';
    final state = DarkestWorldNavigationState(
      previous: previous,
      current: current,
      next: next,
      related: related,
      source: source,
      entryPoint: 'detail',
      originId: 'origin-1',
    );

    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);

    expect(telemetry.signal, 'MIDDLE_C2_R2');
    expect(telemetry.position, 'MIDDLE');
    expect(telemetry.continuityCount, 2);
    expect(telemetry.relatedCount, 2);
    expect(telemetry.currentId, 'current');
    expect(telemetry.previousId, 'prev');
    expect(telemetry.nextId, 'next');
    expect(telemetry.relatedIds, ['rel-1', 'rel-2']);
    expect(telemetry.routeLabel, 'content_detail / DETAIL');
    expect(telemetry.originLabel, 'LINKED');
    expect(telemetry.continuityMode, 'SEQUENCED');
    expect(telemetry.presentationMode, 'FULL');
    expect(telemetry.signalBand, 'HIGH');
    expect(telemetry.signalTitle, 'ARCHIVE SIGNAL PEAK');
    expect(telemetry.canGoPrevious, isTrue);
    expect(telemetry.canGoNext, isTrue);
  });

  test('single local item stays a core signal', () {
    final state = DarkestWorldNavigationState(
      previous: null,
      current: item('solo', 'Solo Game'),
      next: null,
      related: const [],
      source: 'browser',
    );

    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);

    expect(telemetry.signal, 'SINGLE_C0_R0');
    expect(telemetry.continuityMode, 'ISOLATED');
    expect(telemetry.continuityLabel, 'CURRENT ONLY');
    expect(telemetry.presentationMode, 'CORE');
    expect(telemetry.relatedLabel, 'NONE');
    expect(telemetry.canGoPrevious, isFalse);
    expect(telemetry.canGoNext, isFalse);
    expect(telemetry.originLabel, 'LOCAL');
  });

  test('related presentation limits remain deterministic', () {
    final related = List.generate(7, (i) => item('rel-$i', 'Related $i'));
    final state = DarkestWorldNavigationState(
      previous: item('prev', 'Previous'),
      current: item('current', 'Current'),
      next: item('next', 'Next'),
      related: related,
      source: 'archive',
    );

    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);

    expect(telemetry.visibleRelatedCount, 5);
    expect(telemetry.compactVisibleRelatedCount, 3);
    expect(telemetry.relatedOverflowCount, 2);
    expect(telemetry.compactRelatedOverflowCount, 4);
    expect(telemetry.relatedLabel, '5+ ACTIVE');
  });
}

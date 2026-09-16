import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';
import 'package:darkest_world/core/darkest_world_archive_telemetry.dart';
import 'package:darkest_world/core/darkest_world_navigation_state.dart';

ContentItem _item(String id) => ContentItem.fromRow({
  'id': id,
  'content_type': 'game',
  'title': id,
  'slug': id,
});

DarkestWorldArchiveTelemetry _telemetry({
  ContentItem? previous,
  ContentItem? next,
  int relatedCount = 0,
}) {
  return DarkestWorldArchiveTelemetry.fromNavigation(
    DarkestWorldNavigationState(
      previous: previous,
      current: _item('current'),
      next: next,
      related: List.generate(relatedCount, (i) => _item('related-$i')),
      source: 'detail',
    ),
  );
}

void main() {
  test('START, MIDDLE and END continuity labels remain stable', () {
    final start = _telemetry(next: _item('next'));
    final middle = _telemetry(previous: _item('previous'), next: _item('next'));
    final end = _telemetry(previous: _item('previous'));

    expect(start.position, 'START');
    expect(start.continuityLabel, 'CURRENT / NEXT');
    expect(middle.position, 'MIDDLE');
    expect(middle.continuityLabel, 'PREVIOUS / CURRENT / NEXT');
    expect(end.position, 'END');
    expect(end.continuityLabel, 'PREVIOUS / CURRENT');
  });

  test('signal intensity crosses the documented LOW and ACTIVE bands', () {
    final low = _telemetry();
    final active = _telemetry(next: _item('next'), relatedCount: 1);
    final high = _telemetry(
      previous: _item('previous'),
      next: _item('next'),
      relatedCount: 6,
    );

    expect(low.signalBand, 'LOW');
    expect(low.signalTitle, 'ARCHIVE SIGNAL CORE');
    expect(active.signalBand, 'ACTIVE');
    expect(active.signalTitle, 'ARCHIVE SIGNAL ACTIVE');
    expect(high.signalBand, 'HIGH');
    expect(high.signalTitle, 'ARCHIVE SIGNAL PEAK');
  });

  test('related visibility limits preserve source order and overflow', () {
    final telemetry = _telemetry(relatedCount: 7);

    expect(telemetry.visibleRelatedCount, 5);
    expect(telemetry.compactVisibleRelatedCount, 3);
    expect(telemetry.relatedOverflowCount, 2);
    expect(telemetry.compactRelatedOverflowCount, 4);
    expect(telemetry.relatedLabel, '5+ ACTIVE');
  });
}

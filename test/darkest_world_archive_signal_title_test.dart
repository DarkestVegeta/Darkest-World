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

DarkestWorldArchiveTelemetry _telemetry({int related = 0, bool linked = false}) {
  return DarkestWorldArchiveTelemetry.fromNavigation(
    DarkestWorldNavigationState(
      previous: _item('previous'),
      current: _item('current'),
      next: _item('next'),
      related: List.generate(related, (i) => _item('related-$i')),
      source: 'detail',
      originId: linked ? 'origin' : null,
    ),
  );
}

void main() {
  test('signal title follows the normalized signal band', () {
    expect(_telemetry().signalTitle, 'ARCHIVE SIGNAL ACTIVE');
    expect(_telemetry(related: 2, linked: true).signalTitle, 'ARCHIVE SIGNAL PEAK');
  });
}

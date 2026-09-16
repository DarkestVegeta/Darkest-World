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

void main() {
  test('archive metrics preserve bounded related presentation values', () {
    final state = DarkestWorldNavigationState(
      previous: _item('previous'),
      current: _item('current'),
      next: _item('next'),
      related: List.generate(20, (i) => _item('related-$i')),
      source: 'detail',
    );
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);

    expect(telemetry.relatedCount, 20);
    expect(telemetry.visibleRelatedCount, 5);
    expect(telemetry.compactVisibleRelatedCount, 3);
    expect(telemetry.relatedOverflowCount, 15);
    expect(telemetry.compactRelatedOverflowCount, 17);
  });
}

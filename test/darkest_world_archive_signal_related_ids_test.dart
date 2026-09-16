import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';
import 'package:darkest_world/core/darkest_world_archive_telemetry.dart';
import 'package:darkest_world/core/darkest_world_navigation_state.dart';

ContentItem _item(String id) => ContentItem.fromRow({'id': id, 'content_type': 'game', 'title': id, 'slug': id});

void main() {
  test('related identity list follows source order', () {
    final state = DarkestWorldNavigationState(
      previous: null,
      current: _item('current'),
      next: null,
      related: [_item('third'), _item('first'), _item('second')],
      source: 'detail',
    );
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    expect(telemetry.relatedIds, ['third', 'first', 'second']);
  });
}

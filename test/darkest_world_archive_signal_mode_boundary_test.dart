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
  test('full mode requires both continuity links and related content', () {
    final state = DarkestWorldNavigationState(
      previous: _item('previous'),
      current: _item('current'),
      next: _item('next'),
      related: [_item('related')],
      source: 'detail',
    );
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    expect(telemetry.presentationMode, 'FULL');
  });

  test('a complete chain without related content stays connected', () {
    final state = DarkestWorldNavigationState(
      previous: _item('previous'),
      current: _item('current'),
      next: _item('next'),
      related: const [],
      source: 'detail',
    );
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
    expect(telemetry.presentationMode, 'CONNECTED');
  });
}

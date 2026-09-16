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
  test('archive telemetry exposes current and route metadata without mutation', () {
    final state = DarkestWorldNavigationState(
      previous: _item('previous'),
      current: _item('current'),
      next: null,
      related: const [],
      source: 'detail',
      entryPoint: 'galaxy',
    );
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);

    expect(telemetry.currentLabel, 'current');
    expect(telemetry.routeLabel, 'detail / GALAXY');
    expect(telemetry.position, 'END');
    expect(telemetry.continuityLabel, 'PREVIOUS / CURRENT');
  });
}

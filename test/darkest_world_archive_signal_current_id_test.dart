import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';
import 'package:darkest_world/core/darkest_world_archive_telemetry.dart';
import 'package:darkest_world/core/darkest_world_navigation_state.dart';

void main() {
  test('current label falls back when current identity is blank', () {
    final current = ContentItem.fromRow({'id': 'current', 'content_type': 'game', 'title': 'Current', 'slug': 'current'});
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(
      DarkestWorldNavigationState(previous: null, current: current, next: null, related: const [], source: 'detail'),
    );
    expect(telemetry.currentLabel, 'current');
  });
}

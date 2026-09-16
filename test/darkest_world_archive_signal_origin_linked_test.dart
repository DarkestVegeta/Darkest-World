import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';
import 'package:darkest_world/core/darkest_world_archive_telemetry.dart';
import 'package:darkest_world/core/darkest_world_navigation_state.dart';

ContentItem _item(String id) => ContentItem.fromRow({'id': id, 'content_type': 'game', 'title': id, 'slug': id});

void main() {
  test('linked origin contributes to archive signal intensity', () {
    final base = DarkestWorldArchiveTelemetry.fromNavigation(
      DarkestWorldNavigationState(previous: null, current: _item('c'), next: null, related: const [], source: 'detail'),
    );
    final linked = DarkestWorldArchiveTelemetry.fromNavigation(
      DarkestWorldNavigationState(previous: null, current: _item('c'), next: null, related: const [], source: 'detail', originId: 'origin'),
    );
    expect(linked.signalIntensity, greaterThan(base.signalIntensity));
  });
}

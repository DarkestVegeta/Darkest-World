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
  test('missing origin remains explicitly local', () {
    final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(
      DarkestWorldNavigationState(
        previous: null,
        current: _item('current'),
        next: null,
        related: const [],
        source: 'detail',
      ),
    );

    expect(telemetry.originLabel, 'LOCAL');
    expect(telemetry.signalSummary, contains('LOCAL'));
  });
}

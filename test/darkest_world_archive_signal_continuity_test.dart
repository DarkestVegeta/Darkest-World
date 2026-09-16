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
  test('continuity labels describe every chain boundary', () {
    final cases = <DarkestWorldNavigationState>[
      DarkestWorldNavigationState(previous: null, current: _item('s'), next: null, related: const [], source: 'x'),
      DarkestWorldNavigationState(previous: null, current: _item('s'), next: _item('n'), related: const [], source: 'x'),
      DarkestWorldNavigationState(previous: _item('p'), current: _item('s'), next: null, related: const [], source: 'x'),
      DarkestWorldNavigationState(previous: _item('p'), current: _item('s'), next: _item('n'), related: const [], source: 'x'),
    ];
    expect(DarkestWorldArchiveTelemetry.fromNavigation(cases[0]).continuityLabel, 'CURRENT ONLY');
    expect(DarkestWorldArchiveTelemetry.fromNavigation(cases[1]).continuityLabel, 'CURRENT / NEXT');
    expect(DarkestWorldArchiveTelemetry.fromNavigation(cases[2]).continuityLabel, 'PREVIOUS / CURRENT');
    expect(DarkestWorldArchiveTelemetry.fromNavigation(cases[3]).continuityLabel, 'PREVIOUS / CURRENT / NEXT');
  });
}

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
  test('archive telemetry remains deterministic for the same navigation state', () {
    final state = DarkestWorldNavigationState(
      previous: _item('prev'),
      current: _item('current'),
      next: _item('next'),
      related: [_item('r1'), _item('r2')],
      source: 'detail',
      entryPoint: 'detail',
      originId: 'origin',
    );

    final first = DarkestWorldArchiveTelemetry.fromNavigation(state);
    final second = DarkestWorldArchiveTelemetry.fromNavigation(state);

    expect(first.signal, second.signal);
    expect(first.signalIntensity, second.signalIntensity);
    expect(first.signalBand, second.signalBand);
    expect(first.presentationMode, second.presentationMode);
    expect(first.relatedIds, second.relatedIds);
  });
}

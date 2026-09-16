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
  test('archive telemetry intensity stays bounded across signal sizes', () {
    final states = <DarkestWorldNavigationState>[
      DarkestWorldNavigationState(
        previous: null,
        current: _item('solo'),
        next: null,
        related: const [],
        source: 'browser',
      ),
      DarkestWorldNavigationState(
        previous: _item('prev'),
        current: _item('current'),
        next: _item('next'),
        related: List.generate(12, (i) => _item('related-$i')),
        source: 'detail',
        originId: 'origin',
      ),
    ];

    for (final state in states) {
      final telemetry = DarkestWorldArchiveTelemetry.fromNavigation(state);
      expect(telemetry.signalIntensity, inInclusiveRange(0.0, 1.0));
      expect({'LOW', 'ACTIVE', 'HIGH'}, contains(telemetry.signalBand));
    }
  });

  test('presentation mode is driven only by shared navigation telemetry', () {
    final connected = DarkestWorldArchiveTelemetry.fromNavigation(
      DarkestWorldNavigationState(
        previous: null,
        current: _item('current'),
        next: _item('next'),
        related: const [],
        source: 'detail',
      ),
    );

    expect(connected.presentationMode, 'CONNECTED');
    expect(connected.continuityState, contains('SEQUENCED'));
    expect(connected.routeLabel, 'detail / DIRECT');
  });
}

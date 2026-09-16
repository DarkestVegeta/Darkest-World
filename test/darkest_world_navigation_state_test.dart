import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';
import 'package:darkest_world/core/darkest_world_navigation_state.dart';

ContentItem _item(String id, String title) => ContentItem.fromRow({
  'id': id,
  'content_type': 'game',
  'title': title,
  'slug': id,
});

void main() {
  test('navigation state derives stable archive signal and position', () {
    final state = DarkestWorldNavigationState(
      previous: _item('prev', 'Previous'),
      current: _item('current', 'Current'),
      next: _item('next', 'Next'),
      related: [_item('rel', 'Related')],
      source: 'detail',
      entryPoint: 'detail_view',
      originId: 'origin',
    );

    expect(state.previousId, 'prev');
    expect(state.currentId, 'current');
    expect(state.nextId, 'next');
    expect(state.relatedIds, ['rel']);
    expect(state.continuityCount, 2);
    expect(state.navigationPosition, 'MIDDLE');
    expect(state.archiveSignal, 'MIDDLE_C2_R1');
    expect(state.hasOrigin, isTrue);
    expect(state.entryLabel, 'DETAIL VIEW');
  });

  test('navigation state identifies start and end boundaries', () {
    final start = DarkestWorldNavigationState(
      previous: null,
      current: _item('start', 'Start'),
      next: _item('next', 'Next'),
      related: const [],
      source: 'browser',
    );
    final end = DarkestWorldNavigationState(
      previous: _item('prev', 'Previous'),
      current: _item('end', 'End'),
      next: null,
      related: const [],
      source: 'browser',
    );

    expect(start.navigationPosition, 'START');
    expect(start.continuityCount, 1);
    expect(end.navigationPosition, 'END');
    expect(end.continuityCount, 1);
  });
}

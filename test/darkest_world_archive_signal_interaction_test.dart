import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';
import 'package:darkest_world/core/darkest_world_navigation_state.dart';
import 'package:darkest_world/widgets/archive_signal_telemetry_lens.dart';

ContentItem _item(String id, String title) => ContentItem.fromRow({
  'id': id,
  'content_type': 'game',
  'title': title,
  'slug': id,
});

void main() {
  testWidgets('continuity and related taps route through supplied callbacks', (tester) async {
    final previous = _item('previous', 'Previous Game');
    final current = _item('current', 'Current Game');
    final next = _item('next', 'Next Game');
    final related = _item('related', 'Related Game');
    ContentItem? previousTap;
    ContentItem? nextTap;
    ContentItem? relatedTap;

    final state = DarkestWorldNavigationState(
      previous: previous,
      current: current,
      next: next,
      related: [related],
      source: 'detail',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(
          state: state,
          onPreviousTap: (item) => previousTap = item,
          onNextTap: (item) => nextTap = item,
          onRelatedTap: (item) => relatedTap = item,
        ),
      ),
    ));

    await tester.tap(find.text('PREVIOUS GAME'));
    await tester.tap(find.text('NEXT GAME'));
    await tester.tap(find.text('RELATED GAME'));
    await tester.pump();

    expect(previousTap?.id, 'previous');
    expect(nextTap?.id, 'next');
    expect(relatedTap?.id, 'related');
  });
}

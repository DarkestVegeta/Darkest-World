import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';
import 'package:darkest_world/core/darkest_world_navigation_state.dart';
import 'package:darkest_world/widgets/archive_signal_telemetry_lens.dart';

ContentItem _item(String id) => ContentItem.fromRow({
  'id': id,
  'content_type': 'game',
  'title': id,
  'slug': id,
});

void main() {
  testWidgets('archive signal renders a bounded related constellation', (tester) async {
    final state = DarkestWorldNavigationState(
      previous: null,
      current: _item('current'),
      next: null,
      related: List.generate(6, (i) => _item('related-$i')),
      source: 'detail',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(state: state),
      ),
    ));

    expect(find.text('5+ ACTIVE'), findsOneWidget);
    expect(find.text('RELATED-0'), findsOneWidget);
    expect(find.text('RELATED-4'), findsOneWidget);
    expect(find.text('RELATED-5'), findsNothing);
  });
}

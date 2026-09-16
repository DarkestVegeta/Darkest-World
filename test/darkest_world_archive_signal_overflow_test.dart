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
  testWidgets('related overflow remains visible on the archive signal rail', (tester) async {
    final related = List.generate(7, (i) => _item('related-$i'));
    final state = DarkestWorldNavigationState(
      previous: _item('prev'),
      current: _item('current'),
      next: _item('next'),
      related: related,
      source: 'detail',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(state: state),
      ),
    ));

    expect(find.text('+2'), findsOneWidget);
  });
}

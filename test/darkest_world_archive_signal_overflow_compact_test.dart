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
  testWidgets('compact related rail exposes compact overflow count', (tester) async {
    final state = DarkestWorldNavigationState(
      previous: _item('prev'),
      current: _item('current'),
      next: _item('next'),
      related: List.generate(4, (i) => _item('related-$i')),
      source: 'detail',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(state: state, compact: true),
      ),
    ));

    expect(find.text('+1'), findsOneWidget);
  });
}

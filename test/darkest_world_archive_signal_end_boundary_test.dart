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
  testWidgets('end boundary disables next navigation while retaining previous', (tester) async {
    final state = DarkestWorldNavigationState(
      previous: _item('previous'),
      current: _item('current'),
      next: null,
      related: const [],
      source: 'detail',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ArchiveSignalTelemetryLens(state: state)),
    ));

    expect(find.text('PREVIOUS'), findsOneWidget);
    expect(find.text('NO NEXT'), findsOneWidget);
  });
}

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
  testWidgets('archive lens accepts boundary phases', (tester) async {
    final state = DarkestWorldNavigationState(
      previous: null,
      current: _item('current'),
      next: _item('next'),
      related: const [],
      source: 'detail',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(state: state, phase: 0.0),
      ),
    ));
    expect(find.text('START_C1_R0'), findsOneWidget);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(state: state, phase: 1.0),
      ),
    ));
    expect(find.text('START_C1_R0'), findsOneWidget);
  });
}

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
  testWidgets('compact archive lens keeps the core navigation labels visible', (tester) async {
    final state = DarkestWorldNavigationState(
      previous: _item('prev', 'Previous'),
      current: _item('current', 'Current'),
      next: _item('next', 'Next'),
      related: const [],
      source: 'detail',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(state: state, compact: true),
      ),
    ));

    expect(find.text('ARCHIVE SIGNAL'), findsOneWidget);
    expect(find.text('MIDDLE_C2_R0'), findsOneWidget);
    expect(find.text('PREVIOUS'), findsOneWidget);
    expect(find.text('CURRENT'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(find.text('NO RELATED SIGNALS'), findsOneWidget);
  });
}

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
  testWidgets('archive signal lens renders continuity and related rails', (tester) async {
    final previous = _item('prev', 'Previous');
    final current = _item('current', 'Current');
    final next = _item('next', 'Next');
    final related = [_item('related-1', 'Related One'), _item('related-2', 'Related Two')];

    final state = DarkestWorldNavigationState(
      previous: previous,
      current: current,
      next: next,
      related: related,
      source: 'content_detail',
      entryPoint: 'detail',
      originId: 'origin',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(
          state: state,
          phase: .25,
          onPreviousTap: (_) {},
          onNextTap: (_) {},
          onRelatedTap: (_) {},
        ),
      ),
    ));

    expect(find.text('ARCHIVE SIGNAL'), findsOneWidget);
    expect(find.textContaining('PREVIOUS'), findsWidgets);
    expect(find.textContaining('CURRENT'), findsWidgets);
    expect(find.textContaining('NEXT'), findsWidgets);
    expect(find.textContaining('RELATED ONE'), findsOneWidget);
    expect(find.textContaining('RELATED TWO'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);
    expect(find.text('FULL'), findsOneWidget);
  });

  testWidgets('archive signal lens renders isolated core without related content', (tester) async {
    final state = DarkestWorldNavigationState(
      previous: null,
      current: _item('solo', 'Solo'),
      next: null,
      related: const [],
      source: 'browser',
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ArchiveSignalTelemetryLens(state: state, compact: true),
      ),
    ));

    expect(find.text('ARCHIVE SIGNAL'), findsOneWidget);
    expect(find.text('NO RELATED SIGNALS'), findsOneWidget);
    expect(find.text('NO PREVIOUS'), findsOneWidget);
    expect(find.text('NO NEXT'), findsOneWidget);
    expect(find.text('SINGLE_C0_R0'), findsOneWidget);
  });
}

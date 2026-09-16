import 'package:flutter/material.dart';
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
  testWidgets('renders archive signal continuity and related rails', (tester) async {
    final previous = _item('prev', 'Previous Game');
    final current = _item('current', 'Current Game');
    final next = _item('next', 'Next Game');
    final related = [
      _item('rel-1', 'Related One'),
      _item('rel-2', 'Related Two'),
    ];
    final state = DarkestWorldNavigationState(
      previous: previous,
      current: current,
      next: next,
      related: related,
      source: 'content_detail',
      entryPoint: 'detail',
      originId: 'origin-1',
    );

    ContentItem? tappedPrevious;
    ContentItem? tappedNext;
    ContentItem? tappedRelated;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArchiveSignalTelemetryLens(
            state: state,
            phase: .25,
            onPreviousTap: (item) => tappedPrevious = item,
            onNextTap: (item) => tappedNext = item,
            onRelatedTap: (item) => tappedRelated = item,
          ),
        ),
      ),
    );

    expect(find.text('ARCHIVE SIGNAL ACTIVE'), findsOneWidget);
    expect(find.text('MIDDLE_C2_R2'), findsOneWidget);
    expect(find.text('PREVIOUS GAME'), findsOneWidget);
    expect(find.text('CURRENT GAME'), findsOneWidget);
    expect(find.text('NEXT GAME'), findsOneWidget);
    expect(find.text('RELATED ONE'), findsOneWidget);
    expect(find.text('RELATED TWO'), findsOneWidget);

    await tester.tap(find.text('PREVIOUS GAME'));
    expect(tappedPrevious?.id, 'prev');

    await tester.tap(find.text('NEXT GAME'));
    expect(tappedNext?.id, 'next');

    await tester.tap(find.text('RELATED ONE'));
    expect(tappedRelated?.id, 'rel-1');
  });

  testWidgets('disables missing continuity actions and shows core state', (tester) async {
    final state = DarkestWorldNavigationState(
      previous: null,
      current: _item('solo', 'Solo Game'),
      next: null,
      related: const [],
      source: 'browser',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ArchiveSignalTelemetryLens(state: state, phase: 0),
        ),
      ),
    );

    expect(find.text('SINGLE_C0_R0'), findsOneWidget);
    expect(find.text('SOLO GAME'), findsOneWidget);
    expect(find.text('NO PREVIOUS'), findsOneWidget);
    expect(find.text('NO NEXT'), findsOneWidget);
    expect(find.text('NO RELATED SIGNALS'), findsOneWidget);
  });
}

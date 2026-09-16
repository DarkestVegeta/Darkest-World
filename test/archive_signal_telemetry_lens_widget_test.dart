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

DarkestWorldNavigationState _state({
  ContentItem? previous,
  required ContentItem current,
  ContentItem? next,
  List<ContentItem> related = const [],
}) => DarkestWorldNavigationState(
      previous: previous,
      current: current,
      next: next,
      related: related,
      source: 'content_detail',
      entryPoint: 'detail',
      originId: current.id,
    );

Widget _host({
  required DarkestWorldNavigationState state,
  bool compact = false,
  ValueChanged<ContentItem>? onPreviousTap,
  ValueChanged<ContentItem>? onNextTap,
  ValueChanged<ContentItem>? onRelatedTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 1000,
        child: ArchiveSignalTelemetryLens(
          state: state,
          compact: compact,
          phase: .25,
          onPreviousTap: onPreviousTap,
          onNextTap: onNextTap,
          onRelatedTap: onRelatedTap,
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('desktop lens renders shared archive telemetry', (tester) async {
    final current = _item('current', 'Current Game');
    final state = _state(
      previous: _item('prev', 'Previous Game'),
      current: current,
      next: _item('next', 'Next Game'),
      related: [
        _item('related-1', 'Related One'),
        _item('related-2', 'Related Two'),
      ],
    );

    await tester.pumpWidget(_host(state: state));

    expect(find.text('ARCHIVE SIGNAL'), findsOneWidget);
    expect(find.text('MIDDLE_C2_R2'), findsOneWidget);
    expect(find.text('PREVIOUS'), findsOneWidget);
    expect(find.text('CURRENT'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(find.text('RELATED ONE'), findsOneWidget);
    expect(find.text('RELATED TWO'), findsOneWidget);
    expect(find.text('FULL'), findsOneWidget);
    expect(find.text('LINKED'), findsOneWidget);
  });

  testWidgets('compact lens keeps continuity and related rails usable', (tester) async {
    final state = _state(
      previous: _item('prev', 'Previous Game'),
      current: _item('current', 'Current Game'),
      next: _item('next', 'Next Game'),
      related: [
        _item('r1', 'Related One'),
        _item('r2', 'Related Two'),
        _item('r3', 'Related Three'),
        _item('r4', 'Related Four'),
      ],
    );

    await tester.pumpWidget(_host(state: state, compact: true));

    expect(find.text('ARCHIVE SIGNAL'), findsOneWidget);
    expect(find.text('PREVIOUS'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
    expect(find.text('RELATED ONE'), findsOneWidget);
    expect(find.text('RELATED THREE'), findsOneWidget);
    expect(find.text('RELATED FOUR'), findsNothing);
    expect(find.text('+1'), findsOneWidget);
  });

  testWidgets('disabled continuity and empty related state stay quiet', (tester) async {
    final state = _state(current: _item('solo', 'Solo Game'));

    await tester.pumpWidget(_host(state: state));

    expect(find.text('NO PREVIOUS'), findsOneWidget);
    expect(find.text('NO NEXT'), findsOneWidget);
    expect(find.text('NO RELATED SIGNALS'), findsOneWidget);
    expect(find.text('SINGLE_C0_R0'), findsOneWidget);
    expect(find.text('CORE'), findsOneWidget);
  });

  testWidgets('continuity and related rails invoke supplied callbacks', (tester) async {
    final previous = _item('prev', 'Previous Game');
    final next = _item('next', 'Next Game');
    final related = _item('related', 'Related Game');
    final state = _state(
      previous: previous,
      current: _item('current', 'Current Game'),
      next: next,
      related: [related],
    );

    ContentItem? previousResult;
    ContentItem? nextResult;
    ContentItem? relatedResult;

    await tester.pumpWidget(_host(
      state: state,
      onPreviousTap: (item) => previousResult = item,
      onNextTap: (item) => nextResult = item,
      onRelatedTap: (item) => relatedResult = item,
    ));

    await tester.tap(find.text('PREVIOUS'));
    await tester.tap(find.text('NEXT'));
    await tester.tap(find.text('RELATED GAME'));

    expect(previousResult?.id, 'prev');
    expect(nextResult?.id, 'next');
    expect(relatedResult?.id, 'related');
  });
}

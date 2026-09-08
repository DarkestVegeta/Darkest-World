import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';
import 'package:darkest_world/core/timeline_models.dart';
import 'package:darkest_world/core/timeline_repository.dart';
import 'package:darkest_world/screens/timeline_world_page.dart';

class _FakeTimelineRepository extends TimelineRepository {
  final List<TimelineItem> items;

  _FakeTimelineRepository(this.items);

  @override
  Future<List<TimelineItem>> getTimelineItems({
    String? contentType,
    String? franchise,
  }) async {
    if (contentType == null || contentType.isEmpty) return items;
    return items.where((item) => item.contentType.name == contentType).toList();
  }
}

TimelineItem _item({
  required String id,
  required String title,
  required ContentType type,
  required int order,
}) {
  return TimelineItem(
    id: id,
    title: title,
    slug: title.toLowerCase().replaceAll(' ', '-'),
    contentType: type,
    releaseDate: DateTime(1998, 6, 1),
    chronologyOrder: order,
    franchise: 'Test Franchise',
    externalSource: 'test',
    externalId: id,
    description: 'Timeline description',
  );
}

void main() {
  testWidgets('shows live timeline items and type filters', (tester) async {
    final repository = _FakeTimelineRepository([
      _item(id: '1', title: 'Game One', type: ContentType.game, order: 1),
      _item(id: '2', title: 'Movie One', type: ContentType.movie, order: 2),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: TimelineWorldPage(
          title: 'Timeline / Chronology',
          description: 'Chronological navigation across connected content.',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Live chronology'), findsOneWidget);
    expect(find.text('Game One'), findsOneWidget);
    expect(find.text('GAME'), findsOneWidget);
    expect(find.text('MOVIE'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Movie One'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Movie One'), findsOneWidget);
    expect(find.text('MOVIE'), findsOneWidget);
    expect(find.text('Construction layer'), findsNothing);
  });

  testWidgets('shows empty state without creating timeline data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TimelineWorldPage(
          title: 'Timeline / Chronology',
          description: 'Chronological navigation across connected content.',
          repository: _FakeTimelineRepository(const []),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Nog geen timeline-content beschikbaar.'), findsOneWidget);
    expect(find.textContaining('verschijnen ze hier automatisch.'), findsOneWidget);
  });
}

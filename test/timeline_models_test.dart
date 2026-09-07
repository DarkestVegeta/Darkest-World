import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/timeline_models.dart';

void main() {
  group('TimelineItem.fromRow', () {
    test('parses a complete timeline row', () {
      final item = TimelineItem.fromRow({
        'id': 'timeline-1',
        'title': 'Example Game',
        'slug': 'example-game',
        'content_type': 'game',
        'release_date': '1999-04-10',
        'chronology_order': 2,
        'franchise': 'Example',
        'external_source': 'igdb',
        'external_id': '123',
        'description': 'Example description',
      });

      expect(item.id, 'timeline-1');
      expect(item.title, 'Example Game');
      expect(item.contentType.name, 'game');
      expect(item.releaseDate, DateTime(1999, 4, 10));
      expect(item.chronologyOrder, 2);
      expect(item.franchise, 'Example');
      expect(item.externalSource, 'igdb');
      expect(item.externalId, '123');
      expect(item.description, 'Example description');
    });

    test('accepts optional fields as null', () {
      final item = TimelineItem.fromRow({
        'id': 'timeline-2',
        'title': 'Minimal',
        'content_type': 'movie',
      });

      expect(item.slug, isNull);
      expect(item.releaseDate, isNull);
      expect(item.chronologyOrder, isNull);
      expect(item.franchise, isNull);
      expect(item.externalSource, isNull);
      expect(item.externalId, isNull);
      expect(item.description, isNull);
    });

    test('rejects missing required identity fields', () {
      expect(
        () => TimelineItem.fromRow({'title': 'Missing id', 'content_type': 'game'}),
        throwsFormatException,
      );
      expect(
        () => TimelineItem.fromRow({'id': '1', 'content_type': 'game'}),
        throwsFormatException,
      );
    });

    test('rejects unsupported content types', () {
      expect(
        () => TimelineItem.fromRow({
          'id': '1',
          'title': 'Unknown',
          'content_type': 'music',
        }),
        throwsFormatException,
      );
    });

    test('rejects malformed dates and chronology order', () {
      expect(
        () => TimelineItem.fromRow({
          'id': '1',
          'title': 'Bad date',
          'content_type': 'series',
          'release_date': 'not-a-date',
        }),
        throwsFormatException,
      );
      expect(
        () => TimelineItem.fromRow({
          'id': '2',
          'title': 'Bad order',
          'content_type': 'series',
          'chronology_order': 'abc',
        }),
        throwsFormatException,
      );
    });
  });
}

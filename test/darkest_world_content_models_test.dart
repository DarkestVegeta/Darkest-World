import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';

void main() {
  test('ContentItem parses required and optional fields deterministically', () {
    final item = ContentItem.fromRow({
      'id': 'game-1',
      'content_type': 'GAME',
      'title': 'Example Game',
      'slug': 'example-game',
      'original_title': 'Original Example',
      'release_date': '1999-04-12',
      'description': 'Archive entry',
      'franchise': 'Example',
      'external_source': 'igdb',
      'external_id': '123',
      'metadata': {'platform': 'SNES'},
    });

    expect(item.id, 'game-1');
    expect(item.type, ContentType.game);
    expect(item.title, 'Example Game');
    expect(item.slug, 'example-game');
    expect(item.originalTitle, 'Original Example');
    expect(item.releaseDate, DateTime(1999, 4, 12));
    expect(item.franchise, 'Example');
    expect(item.externalSource, 'igdb');
    expect(item.externalId, '123');
    expect(item.metadata['platform'], 'SNES');
  });

  test('ContentItem rejects missing required identity fields', () {
    expect(
      () => ContentItem.fromRow({
        'id': 'game-1',
        'content_type': 'game',
        'title': '',
        'slug': 'game-1',
      }),
      throwsFormatException,
    );
  });

  test('ContentRelation parses relation identity and order', () {
    final relation = ContentRelation.fromRow({
      'from_content_id': 'game-1',
      'to_content_id': 'game-2',
      'relation_type': 'sequel',
      'sort_order': '2',
      'metadata': {'source': 'archive'},
    });

    expect(relation.fromContentId, 'game-1');
    expect(relation.toContentId, 'game-2');
    expect(relation.relationType, 'sequel');
    expect(relation.sortOrder, 2);
    expect(relation.metadata['source'], 'archive');
  });
}

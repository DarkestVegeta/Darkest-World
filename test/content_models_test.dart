import 'package:flutter_test/flutter_test.dart';

import '../lib/core/content_models.dart';

void main() {
  test('maps supported content types case-insensitively', () {
    expect(contentTypeFromValue('game'), ContentType.game);
    expect(contentTypeFromValue('MOVIE'), ContentType.movie);
    expect(contentTypeFromValue(' series '), ContentType.series);
    expect(contentTypeFromValue('music'), ContentType.unknown);
    expect(contentTypeFromValue(null), ContentType.unknown);
  });

  test('parses a complete content row into the typed contract', () {
    final item = ContentItem.fromRow({
      'id': 'content-1',
      'content_type': 'game',
      'title': 'Example Game',
      'slug': 'example-game',
      'original_title': 'Example Game Original',
      'release_date': '1998-04-12',
      'description': 'A test description.',
      'franchise': 'Example',
      'external_source': 'igdb',
      'external_id': '12345',
      'metadata': {'image_url': 'https://example.test/image.jpg'},
    });

    expect(item.id, 'content-1');
    expect(item.type, ContentType.game);
    expect(item.title, 'Example Game');
    expect(item.slug, 'example-game');
    expect(item.releaseDate, DateTime(1998, 4, 12));
    expect(item.franchise, 'Example');
    expect(item.metadata['image_url'], 'https://example.test/image.jpg');
  });

  test('rejects content rows without required identity fields', () {
    expect(
      () => ContentItem.fromRow({
        'id': 'content-1',
        'content_type': 'movie',
        'title': 'Missing Slug',
      }),
      throwsFormatException,
    );
  });

  test('parses a content relation and optional sort order', () {
    final relation = ContentRelation.fromRow({
      'from_content_id': 'a',
      'to_content_id': 'b',
      'relation_type': 'sequel',
      'sort_order': 2,
      'metadata': {'source': 'manual'},
    });

    expect(relation.fromContentId, 'a');
    expect(relation.toContentId, 'b');
    expect(relation.relationType, 'sequel');
    expect(relation.sortOrder, 2);
    expect(relation.metadata['source'], 'manual');
  });
}

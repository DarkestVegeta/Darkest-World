import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_catalog.dart';

void main() {
  ContentItem item({
    required String id,
    required String title,
    String? franchise,
    String? releaseDate,
    ContentType type = ContentType.game,
  }) {
    return ContentItem(
      id: id,
      type: type,
      title: title,
      slug: id,
      originalTitle: null,
      releaseDate: releaseDate == null ? null : DateTime.parse(releaseDate),
      description: null,
      franchise: franchise,
      externalSource: null,
      externalId: null,
      metadata: const {},
    );
  }

  test('empty catalog is safe and returns no navigation or relations', () {
    const catalog = ContentCatalog(items: [], relations: []);

    expect(catalog.itemById('missing'), isNull);
    expect(catalog.relatedItems('missing'), isEmpty);
    expect(catalog.previousOf('missing'), isNull);
    expect(catalog.nextOf('missing'), isNull);
  });

  test('builds typed related items in relation order', () {
    final catalog = ContentCatalog(
      items: [
        item(id: 'a', title: 'A'),
        item(id: 'b', title: 'B'),
        item(id: 'c', title: 'C'),
      ],
      relations: [
        const ContentRelation(
          fromContentId: 'a',
          toContentId: 'c',
          relationType: 'related',
          sortOrder: 2,
          metadata: {},
        ),
        const ContentRelation(
          fromContentId: 'a',
          toContentId: 'b',
          relationType: 'related',
          sortOrder: 1,
          metadata: {},
        ),
      ],
    );

    expect(catalog.relatedItems('a').map((item) => item.id), ['b', 'c']);
  });

  test('builds previous and next within the same franchise and content type', () {
    final catalog = ContentCatalog(
      items: [
        item(id: 'two', title: 'Two', franchise: 'Saga', releaseDate: '2002-01-01'),
        item(id: 'one', title: 'One', franchise: 'Saga', releaseDate: '2001-01-01'),
        item(id: 'three', title: 'Three', franchise: 'Saga', releaseDate: '2003-01-01'),
        item(
          id: 'movie',
          title: 'Movie',
          franchise: 'Saga',
          releaseDate: '2004-01-01',
          type: ContentType.movie,
        ),
      ],
      relations: const [],
    );

    expect(catalog.previousOf('two')?.id, 'one');
    expect(catalog.nextOf('two')?.id, 'three');
    expect(catalog.previousOf('one'), isNull);
    expect(catalog.nextOf('three'), isNull);
  });

  test('fromRows converts the raw contract into typed catalog objects', () {
    final catalog = ContentCatalog.fromRows(
      contentRows: [
        {
          'id': '1',
          'content_type': 'game',
          'title': 'Game',
          'slug': 'game',
        },
      ],
      relationRows: [
        {
          'from_content_id': '1',
          'to_content_id': '2',
          'relation_type': 'related',
          'sort_order': 1,
        },
      ],
    );

    expect(catalog.items.single, isA<ContentItem>());
    expect(catalog.items.single.type, ContentType.game);
    expect(catalog.relations.single.relationType, 'related');
  });
}

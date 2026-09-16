import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_models.dart';

void main() {
  test('unknown content type is preserved as unknown', () {
    final item = ContentItem.fromRow({
      'id': 'mystery',
      'content_type': 'something_new',
      'title': 'Mystery',
      'slug': 'mystery',
    });

    expect(item.type, ContentType.unknown);
  });

  test('blank optional values normalize to null', () {
    final item = ContentItem.fromRow({
      'id': 'optional',
      'content_type': 'movie',
      'title': 'Optional',
      'slug': 'optional',
      'original_title': '  ',
      'description': '',
      'franchise': null,
      'external_source': '  ',
      'external_id': '',
    });

    expect(item.originalTitle, isNull);
    expect(item.description, isNull);
    expect(item.franchise, isNull);
    expect(item.externalSource, isNull);
    expect(item.externalId, isNull);
    expect(item.metadata, isEmpty);
  });
}

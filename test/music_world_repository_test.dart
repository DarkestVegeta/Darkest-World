import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/music_world_repository.dart';

void main() {
  test('parses and normalizes a complete music category row', () {
    final category = MusicWorldCategory.fromMap({
      'id': '  category-1  ',
      'name': '  Stream Music  ',
      'slug': '  stream-music  ',
      'description': '  Music content  ',
      'sort_order': 12.8,
    });

    expect(category.id, 'category-1');
    expect(category.name, 'Stream Music');
    expect(category.slug, 'stream-music');
    expect(category.description, 'Music content');
    expect(category.sortOrder, 12);
  });

  test('normalizes a nullable description to an empty string', () {
    final category = MusicWorldCategory.fromMap({
      'id': '1',
      'name': 'Music',
      'slug': 'music',
      'description': null,
      'sort_order': null,
    });

    expect(category.description, '');
    expect(category.sortOrder, 0);
  });

  test('rejects a missing or blank required identity field', () {
    expect(
      () => MusicWorldCategory.fromMap({
        'id': null,
        'name': 'Music',
        'slug': 'music',
      }),
      throwsFormatException,
    );

    expect(
      () => MusicWorldCategory.fromMap({
        'id': '1',
        'name': '   ',
        'slug': 'music',
      }),
      throwsFormatException,
    );

    expect(
      () => MusicWorldCategory.fromMap({
        'id': '1',
        'name': 'Music',
        'slug': '',
      }),
      throwsFormatException,
    );
  });
}

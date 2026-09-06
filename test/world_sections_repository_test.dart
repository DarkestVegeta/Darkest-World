import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/world_sections_repository.dart';

void main() {
  test('normalizes optional description and sort order', () {
    final section = WorldSection.fromMap({
      'id': 'id-1',
      'name': 'Test World',
      'slug': 'test-world',
      'description': null,
      'sort_order': 3.5,
    });

    expect(section.id, 'id-1');
    expect(section.name, 'Test World');
    expect(section.slug, 'test-world');
    expect(section.description, '');
    expect(section.sortOrder, 3);
  });

  test('rejects a section without a usable id', () {
    expect(
      () => WorldSection.fromMap({
        'id': null,
        'name': 'Test World',
        'slug': 'test-world',
      }),
      throwsFormatException,
    );
  });

  test('rejects a section without a usable name', () {
    expect(
      () => WorldSection.fromMap({
        'id': 'id-1',
        'name': '  ',
        'slug': 'test-world',
      }),
      throwsFormatException,
    );
  });

  test('rejects a section without a usable slug', () {
    expect(
      () => WorldSection.fromMap({
        'id': 'id-1',
        'name': 'Test World',
        'slug': '',
      }),
      throwsFormatException,
    );
  });
}

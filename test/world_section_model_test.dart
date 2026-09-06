import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/world_sections_repository.dart';

void main() {
  test('parses a complete world section row', () {
    final section = WorldSection.fromMap({
      'id': '1',
      'name': 'Game World',
      'slug': 'game-world',
      'description': 'Games',
      'sort_order': 10,
    });

    expect(section.id, '1');
    expect(section.name, 'Game World');
    expect(section.slug, 'game-world');
    expect(section.description, 'Games');
    expect(section.sortOrder, 10);
  });

  test('uses safe defaults for nullable database values', () {
    final section = WorldSection.fromMap({
      'id': null,
      'name': null,
      'slug': null,
      'description': null,
      'sort_order': null,
    });

    expect(section.id, '');
    expect(section.name, 'Untitled');
    expect(section.slug, '');
    expect(section.description, '');
    expect(section.sortOrder, 0);
  });

  test('converts numeric sort order consistently', () {
    final section = WorldSection.fromMap({
      'id': '1',
      'name': 'Events',
      'slug': 'events',
      'description': '',
      'sort_order': 12.8,
    });

    expect(section.sortOrder, 12);
  });
}

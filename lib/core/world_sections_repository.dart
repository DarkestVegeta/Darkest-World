import 'supabase_client.dart';

class WorldSection {
  final String id;
  final String name;
  final String slug;
  final String description;
  final int sortOrder;

  const WorldSection({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.sortOrder,
  });

  factory WorldSection.fromMap(Map<String, dynamic> row) {
    final id = '${row['id'] ?? ''}'.trim();
    final name = '${row['name'] ?? ''}'.trim();
    final slug = '${row['slug'] ?? ''}'.trim();

    if (id.isEmpty) {
      throw const FormatException('World section is missing a usable id.');
    }
    if (name.isEmpty) {
      throw const FormatException('World section is missing a usable name.');
    }
    if (slug.isEmpty) {
      throw const FormatException('World section is missing a usable slug.');
    }

    return WorldSection(
      id: id,
      name: name,
      slug: slug,
      description: '${row['description'] ?? ''}'.trim(),
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class WorldSectionsRepository {
  Future<List<WorldSection>> load() async {
    final response = await supabase
        .from('darkestworld_sections')
        .select('id, name, slug, description, sort_order')
        .order('sort_order')
        .order('name');

    return [
      for (final row in response)
        WorldSection.fromMap(Map<String, dynamic>.from(row)),
    ];
  }
}

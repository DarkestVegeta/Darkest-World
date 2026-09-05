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
    return WorldSection(
      id: '${row['id'] ?? ''}',
      name: '${row['name'] ?? 'Untitled'}',
      slug: '${row['slug'] ?? ''}',
      description: '${row['description'] ?? ''}',
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

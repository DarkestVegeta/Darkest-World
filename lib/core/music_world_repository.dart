import 'supabase_client.dart';

class MusicWorldCategory {
  final String id;
  final String name;
  final String slug;
  final String description;
  final int sortOrder;

  const MusicWorldCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.sortOrder,
  });

  factory MusicWorldCategory.fromMap(Map<String, dynamic> row) {
    final id = '${row['id'] ?? ''}'.trim();
    final name = '${row['name'] ?? ''}'.trim();
    final slug = '${row['slug'] ?? ''}'.trim();

    if (id.isEmpty) {
      throw const FormatException('Music category is missing a usable id.');
    }
    if (name.isEmpty) {
      throw const FormatException('Music category is missing a usable name.');
    }
    if (slug.isEmpty) {
      throw const FormatException('Music category is missing a usable slug.');
    }

    return MusicWorldCategory(
      id: id,
      name: name,
      slug: slug,
      description: '${row['description'] ?? ''}'.trim(),
      sortOrder: (row['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class MusicWorldRepository {
  Future<List<MusicWorldCategory>> loadCategories() async {
    final response = await supabase
        .from('music_world_categories')
        .select('id, name, slug, description, sort_order')
        .order('sort_order')
        .order('name');

    return [
      for (final row in response)
        MusicWorldCategory.fromMap(Map<String, dynamic>.from(row)),
    ];
  }
}

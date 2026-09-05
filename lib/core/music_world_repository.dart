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
    return MusicWorldCategory(
      id: '${row['id']}',
      name: '${row['name']}',
      slug: '${row['slug']}',
      description: '${row['description'] ?? ''}',
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

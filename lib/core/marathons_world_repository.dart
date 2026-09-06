import 'supabase_client.dart';

class WorldMarathon {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;

  const WorldMarathon({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.status,
    required this.startsAt,
    required this.endsAt,
  });

  factory WorldMarathon.fromMap(Map<String, dynamic> row) {
    final id = '${row['id'] ?? ''}'.trim();
    final title = '${row['title'] ?? ''}'.trim();
    final slug = '${row['slug'] ?? ''}'.trim();

    if (id.isEmpty) throw const FormatException('Marathon is missing a usable id.');
    if (title.isEmpty) throw const FormatException('Marathon is missing a usable title.');
    if (slug.isEmpty) throw const FormatException('Marathon is missing a usable slug.');

    DateTime? parseOptionalDate(String key) {
      final value = '${row[key] ?? ''}'.trim();
      if (value.isEmpty) return null;
      final parsed = DateTime.tryParse(value);
      if (parsed == null) throw FormatException('Marathon has an invalid $key.');
      return parsed;
    }

    return WorldMarathon(
      id: id,
      title: title,
      slug: slug,
      description: '${row['description'] ?? ''}'.trim(),
      status: '${row['status'] ?? ''}'.trim(),
      startsAt: parseOptionalDate('starts_at'),
      endsAt: parseOptionalDate('ends_at'),
    );
  }
}

class MarathonsWorldRepository {
  Future<List<WorldMarathon>> loadMarathons() async {
    final response = await supabase
        .from('darkestworld_marathons')
        .select('id, title, slug, description, status, starts_at, ends_at')
        .order('starts_at', nullsFirst: false)
        .order('title')
        .order('id');

    return [
      for (final row in response)
        WorldMarathon.fromMap(Map<String, dynamic>.from(row)),
    ];
  }
}

import 'supabase_client.dart';

class WorldEvent {
  final String id;
  final String title;
  final String slug;
  final String description;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String location;

  const WorldEvent({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.location,
  });

  factory WorldEvent.fromMap(Map<String, dynamic> row) {
    final id = '${row['id'] ?? ''}'.trim();
    final title = '${row['title'] ?? ''}'.trim();
    final slug = '${row['slug'] ?? ''}'.trim();

    if (id.isEmpty) {
      throw const FormatException('World event is missing a usable id.');
    }
    if (title.isEmpty) {
      throw const FormatException('World event is missing a usable title.');
    }
    if (slug.isEmpty) {
      throw const FormatException('World event is missing a usable slug.');
    }

    DateTime? parseOptionalDate(String key) {
      final value = '${row[key] ?? ''}'.trim();
      if (value.isEmpty) return null;
      final parsed = DateTime.tryParse(value);
      if (parsed == null) {
        throw FormatException('World event has an invalid $key.');
      }
      return parsed;
    }

    return WorldEvent(
      id: id,
      title: title,
      slug: slug,
      description: '${row['description'] ?? ''}'.trim(),
      startsAt: parseOptionalDate('starts_at'),
      endsAt: parseOptionalDate('ends_at'),
      location: '${row['location'] ?? ''}'.trim(),
    );
  }
}

class EventsWorldRepository {
  Future<List<WorldEvent>> loadEvents() async {
    final response = await supabase
        .from('darkestworld_events')
        .select('id, title, slug, description, starts_at, ends_at, location')
        .order('starts_at', nullsFirst: false)
        .order('title')
        .order('id');

    return [
      for (final row in response)
        WorldEvent.fromMap(Map<String, dynamic>.from(row)),
    ];
  }
}

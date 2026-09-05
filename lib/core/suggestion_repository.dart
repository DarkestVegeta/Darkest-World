import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

class WorldSuggestion {
  final String id;
  final String source;
  final String contentType;
  final String externalId;
  final String title;
  final String? imageUrl;
  final int soulPoints;
  final String status;
  final String submittedBy;
  final DateTime submittedAt;

  const WorldSuggestion({
    required this.id,
    required this.source,
    required this.contentType,
    required this.externalId,
    required this.title,
    required this.imageUrl,
    required this.soulPoints,
    required this.status,
    required this.submittedBy,
    required this.submittedAt,
  });

  factory WorldSuggestion.fromMap(Map<String, dynamic> row) {
    return WorldSuggestion(
      id: '${row['id']}',
      source: '${row['source']}',
      contentType: '${row['content_type']}',
      externalId: '${row['external_id']}',
      title: '${row['title']}',
      imageUrl: row['image_url']?.toString(),
      soulPoints: (row['soul_points'] as num?)?.toInt() ?? 0,
      status: '${row['status']}',
      submittedBy: '${row['submitted_by']}',
      submittedAt: DateTime.parse('${row['submitted_at']}'),
    );
  }
}

class SuggestionRepository {
  Future<List<WorldSuggestion>> getMySuggestions() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('darkestworld_suggestions')
        .select()
        .eq('submitted_by', user.id)
        .order('submitted_at', ascending: false);

    return [
      for (final row in response)
        WorldSuggestion.fromMap(Map<String, dynamic>.from(row)),
    ];
  }

  Future<void> submit({
    required String source,
    required String contentType,
    required String externalId,
    required String title,
    String? imageUrl,
    required int soulPoints,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw AuthException('Je moet ingelogd zijn om een suggestie te sturen.');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Titel mag niet leeg zijn.');
    }
    if (externalId.trim().isEmpty) {
      throw ArgumentError.value(
        externalId,
        'externalId',
        'Externe ID mag niet leeg zijn.',
      );
    }
    if (soulPoints < 0) {
      throw ArgumentError.value(
        soulPoints,
        'soulPoints',
        'Zielenpunten kunnen niet negatief zijn.',
      );
    }

    await supabase.from('darkestworld_suggestions').insert({
      'submitted_by': user.id,
      'source': source,
      'content_type': contentType,
      'external_id': externalId,
      'title': title.trim(),
      'image_url': imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim(),
      'soul_points': soulPoints,
    });
  }
}

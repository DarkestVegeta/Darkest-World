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
    final id = '${row['id'] ?? ''}'.trim();
    final source = '${row['source'] ?? ''}'.trim();
    final contentType = '${row['content_type'] ?? ''}'.trim();
    final externalId = '${row['external_id'] ?? ''}'.trim();
    final title = '${row['title'] ?? ''}'.trim();
    final status = '${row['status'] ?? ''}'.trim();
    final submittedBy = '${row['submitted_by'] ?? ''}'.trim();

    if (id.isEmpty) throw const FormatException('Suggestion is missing a usable id.');
    if (source.isEmpty) throw const FormatException('Suggestion is missing a usable source.');
    if (contentType.isEmpty) throw const FormatException('Suggestion is missing a usable content type.');
    if (externalId.isEmpty) throw const FormatException('Suggestion is missing a usable external id.');
    if (title.isEmpty) throw const FormatException('Suggestion is missing a usable title.');
    if (status.isEmpty) throw const FormatException('Suggestion is missing a usable status.');
    if (submittedBy.isEmpty) throw const FormatException('Suggestion is missing a usable submitter.');

    final rawSoulPoints = row['soul_points'];
    final soulPoints = switch (rawSoulPoints) {
      null => 0,
      num value => value.toInt(),
      _ => throw const FormatException('Suggestion has malformed soul points.'),
    };

    final rawSubmittedAt = row['submitted_at']?.toString().trim() ?? '';
    final submittedAt = DateTime.tryParse(rawSubmittedAt);
    if (submittedAt == null) {
      throw const FormatException('Suggestion has malformed submitted_at.');
    }

    return WorldSuggestion(
      id: id,
      source: source,
      contentType: contentType,
      externalId: externalId,
      title: title,
      imageUrl: row['image_url']?.toString().trim().isEmpty == true
          ? null
          : row['image_url']?.toString().trim(),
      soulPoints: soulPoints,
      status: status,
      submittedBy: submittedBy,
      submittedAt: submittedAt,
    );
  }
}

class ViewerContentResult {
  final String source;
  final String contentType;
  final String externalId;
  final String title;
  final String? imageUrl;
  final String? releaseDate;
  final String? description;

  const ViewerContentResult({
    required this.source,
    required this.contentType,
    required this.externalId,
    required this.title,
    required this.imageUrl,
    required this.releaseDate,
    required this.description,
  });

  factory ViewerContentResult.fromMap(Map<String, dynamic> row) {
    final source = '${row['external_source'] ?? row['source'] ?? ''}'.trim();
    final contentType = '${row['content_type'] ?? ''}'.trim();
    final externalId = '${row['external_id'] ?? ''}'.trim();
    final title = '${row['title'] ?? ''}'.trim();
    if (source.isEmpty || externalId.isEmpty || title.isEmpty || contentType.isEmpty) {
      throw const FormatException('Viewer content result is incomplete.');
    }

    return ViewerContentResult(
      source: source,
      contentType: contentType,
      externalId: externalId,
      title: title,
      imageUrl: row['image_url']?.toString().trim().isEmpty == true
          ? null
          : row['image_url']?.toString().trim(),
      releaseDate: row['release_date']?.toString().trim().isEmpty == true
          ? null
          : row['release_date']?.toString().trim(),
      description: row['description']?.toString().trim().isEmpty == true
          ? null
          : row['description']?.toString().trim(),
    );
  }
}

class SuggestionRepository {
  static const allowedSources = {'igdb', 'tmdb'};
  static const allowedContentTypes = {'game', 'movie', 'series'};

  static void _validateSourceContentType(String source, String contentType) {
    if (!allowedSources.contains(source)) {
      throw ArgumentError.value(source, 'source', 'Ongeldige externe bron.');
    }
    if (!allowedContentTypes.contains(contentType)) {
      throw ArgumentError.value(contentType, 'contentType', 'Ongeldig contenttype.');
    }
    switch ((source, contentType)) {
      case ('igdb', 'game'):
      case ('tmdb', 'movie'):
      case ('tmdb', 'series'):
        return;
      default:
        throw ArgumentError('Bron en type passen niet bij elkaar.');
    }
  }

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

  Future<List<ViewerContentResult>> searchViewerContent({
    required String source,
    required String contentType,
    required String query,
  }) async {
    _validateSourceContentType(source, contentType);
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return [];

    final functionSource = switch ((source, contentType)) {
      ('igdb', 'game') => 'igdb',
      ('tmdb', 'movie') => 'tmdb_movie',
      ('tmdb', 'series') => 'tmdb_tv',
      _ => throw StateError('Validated source/content type became invalid.'),
    };

    final response = await supabase.functions.invoke(
      'darkestworld-content-import',
      body: {'source': functionSource, 'query': cleanQuery},
    );

    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Externe zoekopdracht gaf geen geldig antwoord.');
    }
    if (data['ok'] != true) {
      throw Exception('${data['error'] ?? 'Externe zoekopdracht mislukt.'}');
    }

    final rawItems = data['items'];
    if (rawItems is! List) return [];
    return [
      for (final row in rawItems)
        if (row is Map)
          ViewerContentResult.fromMap(Map<String, dynamic>.from(row)),
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
    _validateSourceContentType(source, contentType);
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'Titel mag niet leeg zijn.');
    }
    if (externalId.trim().isEmpty) {
      throw ArgumentError.value(externalId, 'externalId', 'Externe ID mag niet leeg zijn.');
    }
    if (soulPoints < 0) {
      throw ArgumentError.value(soulPoints, 'soulPoints', 'Zielenpunten kunnen niet negatief zijn.');
    }

    await supabase.from('darkestworld_suggestions').insert({
      'submitted_by': user.id,
      'source': source,
      'content_type': contentType,
      'external_id': externalId.trim(),
      'title': title.trim(),
      'image_url': imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim(),
      'soul_points': soulPoints,
    });
  }
}

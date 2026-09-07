enum ContentType {
  game,
  movie,
  series,
  unknown,
}

ContentType contentTypeFromValue(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'game':
      return ContentType.game;
    case 'movie':
      return ContentType.movie;
    case 'series':
      return ContentType.series;
    default:
      return ContentType.unknown;
  }
}

class ContentItem {
  final String id;
  final ContentType type;
  final String title;
  final String slug;
  final String? originalTitle;
  final DateTime? releaseDate;
  final String? description;
  final String? franchise;
  final String? externalSource;
  final String? externalId;
  final Map<String, dynamic> metadata;

  const ContentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.slug,
    required this.originalTitle,
    required this.releaseDate,
    required this.description,
    required this.franchise,
    required this.externalSource,
    required this.externalId,
    required this.metadata,
  });

  factory ContentItem.fromRow(Map<String, dynamic> row) {
    final id = '${row['id'] ?? ''}'.trim();
    final title = '${row['title'] ?? ''}'.trim();
    final slug = '${row['slug'] ?? ''}'.trim();
    if (id.isEmpty || title.isEmpty || slug.isEmpty) {
      throw const FormatException('Content row requires id, title and slug.');
    }

    final rawMetadata = row['metadata'];
    final metadata = rawMetadata is Map
        ? Map<String, dynamic>.from(rawMetadata)
        : <String, dynamic>{};

    DateTime? releaseDate;
    final rawReleaseDate = row['release_date'];
    if (rawReleaseDate is DateTime) {
      releaseDate = rawReleaseDate;
    } else if (rawReleaseDate != null && '$rawReleaseDate'.trim().isNotEmpty) {
      releaseDate = DateTime.tryParse('$rawReleaseDate');
    }

    String? optionalString(dynamic value) {
      final normalized = '${value ?? ''}'.trim();
      return normalized.isEmpty ? null : normalized;
    }

    return ContentItem(
      id: id,
      type: contentTypeFromValue(row['content_type']?.toString()),
      title: title,
      slug: slug,
      originalTitle: optionalString(row['original_title']),
      releaseDate: releaseDate,
      description: optionalString(row['description']),
      franchise: optionalString(row['franchise']),
      externalSource: optionalString(row['external_source']),
      externalId: optionalString(row['external_id']),
      metadata: metadata,
    );
  }
}

class ContentRelation {
  final String fromContentId;
  final String toContentId;
  final String relationType;
  final int? sortOrder;
  final Map<String, dynamic> metadata;

  const ContentRelation({
    required this.fromContentId,
    required this.toContentId,
    required this.relationType,
    required this.sortOrder,
    required this.metadata,
  });

  factory ContentRelation.fromRow(Map<String, dynamic> row) {
    final from = '${row['from_content_id'] ?? ''}'.trim();
    final to = '${row['to_content_id'] ?? ''}'.trim();
    final relationType = '${row['relation_type'] ?? ''}'.trim();
    if (from.isEmpty || to.isEmpty || relationType.isEmpty) {
      throw const FormatException(
        'Content relation requires from_content_id, to_content_id and relation_type.',
      );
    }

    final rawMetadata = row['metadata'];
    return ContentRelation(
      fromContentId: from,
      toContentId: to,
      relationType: relationType,
      sortOrder: row['sort_order'] is int
          ? row['sort_order'] as int
          : int.tryParse('${row['sort_order'] ?? ''}'),
      metadata: rawMetadata is Map
          ? Map<String, dynamic>.from(rawMetadata)
          : <String, dynamic>{},
    );
  }
}

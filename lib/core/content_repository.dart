import 'content_models.dart';
import 'supabase_client.dart';

class FranchiseNavigation {
  final Map<String, dynamic>? previous;
  final Map<String, dynamic> current;
  final Map<String, dynamic>? next;

  const FranchiseNavigation({
    required this.previous,
    required this.current,
    required this.next,
  });
}

class TypedFranchiseNavigation {
  final ContentItem? previous;
  final ContentItem current;
  final ContentItem? next;

  const TypedFranchiseNavigation({
    required this.previous,
    required this.current,
    required this.next,
  });
}

class ContentRepository {
  static const int pageSize = 36;

  Future<List<Map<String, dynamic>>> getContentPage({
    String? type,
    int page = 0,
  }) async {
    if (page < 0) throw ArgumentError.value(page, 'page', 'Cannot be negative.');

    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase.from('darkestworld_content').select();
    final normalizedType = type?.trim();
    if (normalizedType != null && normalizedType.isNotEmpty) {
      query = query.eq('content_type', normalizedType);
    }

    final response = await query.order('title').order('id').range(from, to);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<ContentItem>> getContentItemsPage({
    String? type,
    int page = 0,
  }) async {
    final rows = await getContentPage(type: type, page: page);
    return [for (final row in rows) ContentItem.fromRow(row)];
  }

  Future<Map<String, dynamic>?> getContentById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    final response = await supabase
        .from('darkestworld_content')
        .select()
        .eq('id', normalizedId)
        .maybeSingle();
    return response == null ? null : Map<String, dynamic>.from(response);
  }

  Future<ContentItem?> getContentItemById(String id) async {
    final row = await getContentById(id);
    return row == null ? null : ContentItem.fromRow(row);
  }

  static FranchiseNavigation? buildFranchiseNavigation({
    required Map<String, dynamic> current,
    required List<Map<String, dynamic>> content,
    required List<Map<String, dynamic>> timeline,
  }) {
    final currentId = '${current['id'] ?? ''}'.trim();
    if (currentId.isEmpty) return null;

    final fallback = [
      for (final row in content) Map<String, dynamic>.from(row),
    ];
    if (!fallback.any((row) => '${row['id'] ?? ''}'.trim() == currentId)) {
      fallback.add(Map<String, dynamic>.from(current));
    }
    fallback.sort((a, b) {
      final aDate = '${a['release_date'] ?? ''}'.trim();
      final bDate = '${b['release_date'] ?? ''}'.trim();
      if (aDate.isEmpty && bDate.isNotEmpty) return 1;
      if (aDate.isNotEmpty && bDate.isEmpty) return -1;
      final dateCompare = aDate.compareTo(bDate);
      if (dateCompare != 0) return dateCompare;
      final titleCompare = '${a['title'] ?? ''}'.trim().compareTo('${b['title'] ?? ''}'.trim());
      if (titleCompare != 0) return titleCompare;
      return '${a['id'] ?? ''}'.trim().compareTo('${b['id'] ?? ''}'.trim());
    });

    if (timeline.isNotEmpty) {
      final ordered = <Map<String, dynamic>>[];
      for (final row in timeline) {
        final source = row['external_source']?.toString().trim();
        final externalId = row['external_id']?.toString().trim();
        if (source == null || source.isEmpty || externalId == null || externalId.isEmpty) continue;

        Map<String, dynamic>? match;
        for (final item in fallback) {
          if ('${item['external_source'] ?? ''}'.trim() == source &&
              '${item['external_id'] ?? ''}'.trim() == externalId) {
            match = item;
            break;
          }
        }
        if (match != null &&
            !ordered.any((item) => '${item['id'] ?? ''}'.trim() == '${match!['id'] ?? ''}'.trim())) {
          ordered.add(match);
        }
      }

      final timelineIndex =
          ordered.indexWhere((item) => '${item['id'] ?? ''}'.trim() == currentId);
      if (timelineIndex >= 0) {
        return FranchiseNavigation(
          previous: timelineIndex > 0 ? ordered[timelineIndex - 1] : null,
          current: current,
          next: timelineIndex + 1 < ordered.length ? ordered[timelineIndex + 1] : null,
        );
      }
    }

    final fallbackIndex =
        fallback.indexWhere((item) => '${item['id'] ?? ''}'.trim() == currentId);
    if (fallbackIndex < 0) return null;

    return FranchiseNavigation(
      previous: fallbackIndex > 0 ? fallback[fallbackIndex - 1] : null,
      current: current,
      next: fallbackIndex + 1 < fallback.length ? fallback[fallbackIndex + 1] : null,
    );
  }

  Future<FranchiseNavigation?> getFranchiseNavigation(
    Map<String, dynamic> current,
  ) async {
    final franchise = '${current['franchise'] ?? ''}'.trim();
    final type = '${current['content_type'] ?? ''}'.trim();
    final currentId = '${current['id'] ?? ''}'.trim();
    if (franchise.isEmpty || type.isEmpty || currentId.isEmpty) return null;

    final contentResponse = await supabase
        .from('darkestworld_content')
        .select()
        .eq('franchise', franchise)
        .eq('content_type', type)
        .order('release_date', ascending: true, nullsFirst: false)
        .order('title')
        .order('id');

    final content = [
      for (final row in contentResponse)
        Map<String, dynamic>.from(row),
    ];

    final timelineResponse = await supabase
        .from('darkestworld_timeline')
        .select('title, content_type, release_date, chronology_order, franchise, external_source, external_id')
        .eq('franchise', franchise)
        .eq('content_type', type)
        .order('chronology_order', nullsFirst: false)
        .order('release_date', nullsFirst: false)
        .order('title');

    return buildFranchiseNavigation(
      current: current,
      content: content,
      timeline: [
        for (final row in timelineResponse)
          Map<String, dynamic>.from(row),
      ],
    );
  }

  Future<TypedFranchiseNavigation?> getTypedFranchiseNavigation(
    ContentItem current,
  ) async {
    final rawNavigation = await getFranchiseNavigation(_contentItemToRow(current));
    if (rawNavigation == null) return null;
    return TypedFranchiseNavigation(
      previous: rawNavigation.previous == null
          ? null
          : ContentItem.fromRow(rawNavigation.previous!),
      current: ContentItem.fromRow(rawNavigation.current),
      next: rawNavigation.next == null
          ? null
          : ContentItem.fromRow(rawNavigation.next!),
    );
  }

  Map<String, dynamic> _contentItemToRow(ContentItem item) {
    return {
      'id': item.id,
      'content_type': item.type.name,
      'title': item.title,
      'slug': item.slug,
      'original_title': item.originalTitle,
      'release_date': item.releaseDate?.toIso8601String(),
      'description': item.description,
      'franchise': item.franchise,
      'external_source': item.externalSource,
      'external_id': item.externalId,
      'metadata': item.metadata,
    };
  }

  Future<List<Map<String, dynamic>>> getRelatedContent(String contentId) async {
    final normalizedId = contentId.trim();
    if (normalizedId.isEmpty) return [];

    final outgoing = await supabase
        .from('darkestworld_content_relations')
        .select('to_content_id, relation_type, sort_order')
        .eq('from_content_id', normalizedId)
        .order('sort_order');

    final ids = [
      for (final row in outgoing)
        if (row['to_content_id'] != null) '${row['to_content_id']}',
    ];
    if (ids.isEmpty) return [];

    final content = await supabase
        .from('darkestworld_content')
        .select()
        .inFilter('id', ids);

    final byId = <String, Map<String, dynamic>>{
      for (final row in content) '${row['id']}': Map<String, dynamic>.from(row),
    };

    return [for (final id in ids) if (byId.containsKey(id)) byId[id]!];
  }

  Future<List<ContentItem>> getRelatedContentItems(String contentId) async {
    final rows = await getRelatedContent(contentId);
    return [for (final row in rows) ContentItem.fromRow(row)];
  }

  Future<List<Map<String, dynamic>>> getContent({String? type}) {
    return getContentPage(type: type, page: 0);
  }
}

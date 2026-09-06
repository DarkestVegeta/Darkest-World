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

class ContentRepository {
  // Technical batch size. The UI decides how many items are visible.
  static const int pageSize = 36;
  static const int testAssetCount = 10;

  Future<List<Map<String, dynamic>>> getContentPage({
    String? type,
    int page = 0,
  }) async {
    if (page < 0) throw ArgumentError.value(page, 'page', 'Cannot be negative.');

    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase.from('darkestworld_content').select();
    if (type != null) query = query.eq('content_type', type);

    final response = await query.order('title').order('id').range(from, to);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getContentById(String id) async {
    final response = await supabase
        .from('darkestworld_content')
        .select()
        .eq('id', id)
        .maybeSingle();
    return response == null ? null : Map<String, dynamic>.from(response);
  }

  /// Builds the Previous | CURRENT | Next contract from already-loaded rows.
  ///
  /// Timeline rows are authoritative when they identify the current item. If
  /// they are absent or do not contain the current item, the content rows are
  /// used in release-date/title/id order.
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
      final aDate = '${a['release_date'] ?? ''}';
      final bDate = '${b['release_date'] ?? ''}';
      final dateCompare = aDate.compareTo(bDate);
      if (dateCompare != 0) return dateCompare;
      final titleCompare = '${a['title'] ?? ''}'.compareTo('${b['title'] ?? ''}');
      if (titleCompare != 0) return titleCompare;
      return '${a['id'] ?? ''}'.compareTo('${b['id'] ?? ''}');
    });

    if (timeline.isNotEmpty) {
      final ordered = <Map<String, dynamic>>[];
      for (final row in timeline) {
        final source = row['external_source']?.toString();
        final externalId = row['external_id']?.toString();
        if (source == null || externalId == null) continue;

        Map<String, dynamic>? match;
        for (final item in fallback) {
          if ('${item['external_source'] ?? ''}' == source &&
              '${item['external_id'] ?? ''}' == externalId) {
            match = item;
            break;
          }
        }
        if (match != null &&
            !ordered.any((item) => '${item['id'] ?? ''}' == '${match!['id'] ?? ''}')) {
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

  Future<List<Map<String, dynamic>>> getRelatedContent(String contentId) async {
    final outgoing = await supabase
        .from('darkestworld_content_relations')
        .select('to_content_id, relation_type, sort_order')
        .eq('from_content_id', contentId)
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

  Future<List<Map<String, dynamic>>> getAssetPage({
    String? assetType,
    int page = 0,
  }) async {
    if (page < 0) throw ArgumentError.value(page, 'page', 'Cannot be negative.');

    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase.from('storage_assets').select();
    if (assetType != null) query = query.eq('asset_type', assetType);

    // Only assets with a usable public URL belong in the public gallery.
    final response = await query
        .not('public_url', 'is', null)
        .order('title')
        .order('id')
        .range(from, to);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getTestAssets() async {
    final response = await supabase
        .from('storage_assets')
        .select()
        .eq('is_test_asset', true)
        .eq('asset_type', 'snes_sealed')
        .not('public_url', 'is', null)
        .order('title')
        .limit(testAssetCount);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getContent({String? type}) {
    return getContentPage(type: type, page: 0);
  }

  Future<List<Map<String, dynamic>>> getAssets({String? assetType}) {
    return getAssetPage(assetType: assetType, page: 0);
  }
}

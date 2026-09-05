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

  Future<FranchiseNavigation?> getFranchiseNavigation(
    Map<String, dynamic> current,
  ) async {
    final franchise = '${current['franchise'] ?? ''}'.trim();
    final type = '${current['content_type'] ?? ''}'.trim();
    final currentId = '${current['id'] ?? ''}';
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
    if (content.isEmpty) return null;

    var currentIndex = content.indexWhere((row) => '${row['id']}' == currentId);
    if (currentIndex < 0) {
      content.add(current);
      content.sort((a, b) {
        final aDate = '${a['release_date'] ?? ''}';
        final bDate = '${b['release_date'] ?? ''}';
        final dateCompare = aDate.compareTo(bDate);
        if (dateCompare != 0) return dateCompare;
        final titleCompare = '${a['title'] ?? ''}'.compareTo('${b['title'] ?? ''}');
        if (titleCompare != 0) return titleCompare;
        return '${a['id']}'.compareTo('${b['id']}');
      });
      currentIndex = content.indexWhere((row) => '${row['id']}' == currentId);
    }

    // Timeline remains the authoritative future ordering when it has been populated.
    final timelineResponse = await supabase
        .from('darkestworld_timeline')
        .select('title, content_type, release_date, chronology_order, franchise, external_source, external_id')
        .eq('franchise', franchise)
        .eq('content_type', type)
        .order('chronology_order', nullsFirst: false)
        .order('release_date', nullsFirst: false)
        .order('title');

    if (timelineResponse.isNotEmpty) {
      final timeline = List<Map<String, dynamic>>.from(timelineResponse);
      final ordered = <Map<String, dynamic>>[];
      for (final row in timeline) {
        final source = row['external_source']?.toString();
        final externalId = row['external_id']?.toString();
        Map<String, dynamic>? match;
        if (source != null && externalId != null) {
          for (final item in content) {
            if ('${item['external_source'] ?? ''}' == source &&
                '${item['external_id'] ?? ''}' == externalId) {
              match = item;
              break;
            }
          }
        }
        if (match != null && !ordered.any((item) => '${item['id']}' == '${match!['id']}')) {
          ordered.add(match);
        }
      }
      if (ordered.any((item) => '${item['id']}' == currentId)) {
        final orderedIndex = ordered.indexWhere((item) => '${item['id']}' == currentId);
        return FranchiseNavigation(
          previous: orderedIndex > 0 ? ordered[orderedIndex - 1] : null,
          current: current,
          next: orderedIndex + 1 < ordered.length ? ordered[orderedIndex + 1] : null,
        );
      }
    }

    return FranchiseNavigation(
      previous: currentIndex > 0 ? content[currentIndex - 1] : null,
      current: current,
      next: currentIndex + 1 < content.length ? content[currentIndex + 1] : null,
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

import 'supabase_client.dart';
import 'timeline_models.dart';

class TimelineRepository {
  static const int pageSize = 36;

  Future<List<Map<String, dynamic>>> getTimelinePage({
    String? contentType,
    String? franchise,
    int page = 0,
  }) async {
    if (page < 0) throw ArgumentError.value(page, 'page', 'Cannot be negative.');

    final from = page * pageSize;
    final to = from + pageSize - 1;
    var query = supabase.from('darkestworld_timeline').select();

    final normalizedType = contentType?.trim();
    if (normalizedType != null && normalizedType.isNotEmpty) {
      query = query.eq('content_type', normalizedType);
    }

    final normalizedFranchise = franchise?.trim();
    if (normalizedFranchise != null && normalizedFranchise.isNotEmpty) {
      query = query.eq('franchise', normalizedFranchise);
    }

    final response = await query
        .order('chronology_order', nullsFirst: false)
        .order('release_date', nullsFirst: false)
        .order('title')
        .order('id')
        .range(from, to);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<TimelineItem>> getTimelineItemsPage({
    String? contentType,
    String? franchise,
    int page = 0,
  }) async {
    final rows = await getTimelinePage(
      contentType: contentType,
      franchise: franchise,
      page: page,
    );
    return [for (final row in rows) TimelineItem.fromRow(row)];
  }

  Future<List<TimelineItem>> getTimelineItems({
    String? contentType,
    String? franchise,
  }) {
    return getTimelineItemsPage(
      contentType: contentType,
      franchise: franchise,
      page: 0,
    );
  }
}

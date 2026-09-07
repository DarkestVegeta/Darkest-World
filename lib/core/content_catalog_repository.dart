import 'content_catalog.dart';
import 'content_repository.dart';
import 'supabase_client.dart';

class ContentCatalogRepository {
  static const int pageSize = ContentRepository.pageSize;

  Future<ContentCatalog> getCatalogPage({
    String? type,
    int page = 0,
  }) async {
    if (page < 0) throw ArgumentError.value(page, 'page', 'Cannot be negative.');

    final contentRepository = ContentRepository();
    final items = await contentRepository.getContentPage(type: type, page: page);
    if (items.isEmpty) {
      return const ContentCatalog(items: [], relations: []);
    }

    final ids = [
      for (final row in items)
        if (row['id'] != null) '${row['id']}'.trim(),
    ];
    if (ids.isEmpty) {
      return ContentCatalog.fromRows(
        contentRows: items,
        relationRows: const [],
      );
    }

    final relationRows = await supabase
        .from('darkestworld_content_relations')
        .select('from_content_id, to_content_id, relation_type, sort_order, metadata')
        .inFilter('from_content_id', ids)
        .order('sort_order')
        .order('to_content_id');

    return ContentCatalog.fromRows(
      contentRows: items,
      relationRows: [
        for (final row in relationRows) Map<String, dynamic>.from(row),
      ],
    );
  }

  Future<ContentCatalog> getCatalog({String? type}) {
    return getCatalogPage(type: type, page: 0);
  }
}

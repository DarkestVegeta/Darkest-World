import 'content_models.dart';

class ContentCatalog {
  final List<ContentItem> items;
  final List<ContentRelation> relations;

  const ContentCatalog({
    required this.items,
    required this.relations,
  });

  factory ContentCatalog.fromRows({
    required List<Map<String, dynamic>> contentRows,
    required List<Map<String, dynamic>> relationRows,
  }) {
    return ContentCatalog(
      items: [for (final row in contentRows) ContentItem.fromRow(row)],
      relations: [for (final row in relationRows) ContentRelation.fromRow(row)],
    );
  }

  ContentItem? itemById(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    for (final item in items) {
      if (item.id == normalizedId) return item;
    }
    return null;
  }

  List<ContentRelation> relationsFrom(String contentId) {
    final normalizedId = contentId.trim();
    if (normalizedId.isEmpty) return const [];

    final result = [
      for (final relation in relations)
        if (relation.fromContentId == normalizedId) relation,
    ];
    result.sort((a, b) {
      final aOrder = a.sortOrder ?? 1 << 30;
      final bOrder = b.sortOrder ?? 1 << 30;
      final orderCompare = aOrder.compareTo(bOrder);
      if (orderCompare != 0) return orderCompare;
      return a.toContentId.compareTo(b.toContentId);
    });
    return result;
  }

  List<ContentItem> relatedItems(String contentId) {
    final result = <ContentItem>[];
    final seen = <String>{};

    for (final relation in relationsFrom(contentId)) {
      final item = itemById(relation.toContentId);
      if (item != null && seen.add(item.id)) result.add(item);
    }
    return result;
  }

  List<ContentItem> franchiseItems(String contentId) {
    final current = itemById(contentId);
    if (current == null || current.franchise == null) return [];

    final franchise = current.franchise!;
    final result = [
      for (final item in items)
        if (item.franchise == franchise && item.type == current.type) item,
    ];

    result.sort((a, b) {
      final aDate = a.releaseDate;
      final bDate = b.releaseDate;
      if (aDate == null && bDate != null) return 1;
      if (aDate != null && bDate == null) return -1;
      if (aDate != null && bDate != null) {
        final dateCompare = aDate.compareTo(bDate);
        if (dateCompare != 0) return dateCompare;
      }

      final titleCompare = a.title.compareTo(b.title);
      if (titleCompare != 0) return titleCompare;
      return a.id.compareTo(b.id);
    });
    return result;
  }

  ContentItem? previousOf(String contentId) {
    final items = franchiseItems(contentId);
    final index = items.indexWhere((item) => item.id == contentId.trim());
    return index > 0 ? items[index - 1] : null;
  }

  ContentItem? nextOf(String contentId) {
    final items = franchiseItems(contentId);
    final index = items.indexWhere((item) => item.id == contentId.trim());
    return index >= 0 && index + 1 < items.length ? items[index + 1] : null;
  }
}

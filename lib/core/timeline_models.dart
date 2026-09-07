import 'content_models.dart';

class TimelineItem {
  final String id;
  final String title;
  final String? slug;
  final ContentType contentType;
  final DateTime? releaseDate;
  final int? chronologyOrder;
  final String? franchise;
  final String? externalSource;
  final String? externalId;
  final String? description;

  const TimelineItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.contentType,
    required this.releaseDate,
    required this.chronologyOrder,
    required this.franchise,
    required this.externalSource,
    required this.externalId,
    required this.description,
  });

  factory TimelineItem.fromRow(Map<String, dynamic> row) {
    final id = row['id']?.toString().trim() ?? '';
    final title = row['title']?.toString().trim() ?? '';
    final type = contentTypeFromValue(row['content_type']?.toString());

    if (id.isEmpty) throw const FormatException('Timeline item id is required.');
    if (title.isEmpty) throw const FormatException('Timeline item title is required.');
    if (type == ContentType.unknown) {
      throw const FormatException('Timeline item content_type must be game, movie, or series.');
    }

    final releaseDateValue = row['release_date'];
    DateTime? releaseDate;
    if (releaseDateValue != null && releaseDateValue.toString().trim().isNotEmpty) {
      releaseDate = DateTime.tryParse(releaseDateValue.toString());
      if (releaseDate == null) {
        throw const FormatException('Timeline item release_date must be a valid date.');
      }
    }

    final chronologyValue = row['chronology_order'];
    int? chronologyOrder;
    if (chronologyValue != null) {
      if (chronologyValue is num) {
        chronologyOrder = chronologyValue.toInt();
      } else {
        chronologyOrder = int.tryParse(chronologyValue.toString().trim());
        if (chronologyOrder == null) {
          throw const FormatException('Timeline item chronology_order must be an integer.');
        }
      }
    }

    String? optionalText(Object? value) {
      final normalized = value?.toString().trim();
      return normalized == null || normalized.isEmpty ? null : normalized;
    }

    return TimelineItem(
      id: id,
      title: title,
      slug: optionalText(row['slug']),
      contentType: type,
      releaseDate: releaseDate,
      chronologyOrder: chronologyOrder,
      franchise: optionalText(row['franchise']),
      externalSource: optionalText(row['external_source']),
      externalId: optionalText(row['external_id']),
      description: optionalText(row['description']),
    );
  }
}

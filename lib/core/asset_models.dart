class StorageAsset {
  final String id;
  final String dropboxPath;
  final String assetType;
  final String? title;
  final String? publicUrl;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isTestAsset;

  const StorageAsset({
    required this.id,
    required this.dropboxPath,
    required this.assetType,
    required this.title,
    required this.publicUrl,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    required this.isTestAsset,
  });

  factory StorageAsset.fromRow(Map<String, dynamic> row) {
    String requiredText(String key) {
      final value = row[key]?.toString().trim() ?? '';
      if (value.isEmpty) throw FormatException('Missing required field: $key');
      return value;
    }

    String? optionalText(String key) {
      final value = row[key]?.toString().trim();
      return value == null || value.isEmpty ? null : value;
    }

    DateTime requiredDate(String key) {
      final value = row[key]?.toString().trim() ?? '';
      final parsed = DateTime.tryParse(value);
      if (parsed == null) throw FormatException('Invalid $key.');
      return parsed;
    }

    final rawMetadata = row['metadata'];
    final metadata = rawMetadata == null
        ? <String, dynamic>{}
        : rawMetadata is Map
            ? Map<String, dynamic>.from(rawMetadata)
            : throw FormatException('Invalid metadata.');

    final rawTestAsset = row['is_test_asset'];
    if (rawTestAsset is! bool) {
      throw FormatException('Invalid is_test_asset.');
    }

    return StorageAsset(
      id: requiredText('id'),
      dropboxPath: requiredText('dropbox_path'),
      assetType: requiredText('asset_type'),
      title: optionalText('title'),
      publicUrl: optionalText('public_url'),
      metadata: metadata,
      createdAt: requiredDate('created_at'),
      updatedAt: requiredDate('updated_at'),
      isTestAsset: rawTestAsset,
    );
  }

  bool get isPublic => publicUrl != null;
}

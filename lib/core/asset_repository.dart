import 'asset_models.dart';
import 'content_repository.dart';
import 'supabase_client.dart';

class StorageAssetRepository {
  static const int pageSize = ContentRepository.pageSize;
  static const int testAssetCount = 10;

  Future<List<StorageAsset>> getAssetsPage({
    String? assetType,
    int page = 0,
    bool publicOnly = true,
  }) async {
    if (page < 0) throw ArgumentError.value(page, 'page', 'Cannot be negative.');

    final from = page * pageSize;
    final to = from + pageSize - 1;
    var query = supabase.from('storage_assets').select();

    final normalizedType = assetType?.trim();
    if (normalizedType != null && normalizedType.isNotEmpty) {
      query = query.eq('asset_type', normalizedType);
    }
    if (publicOnly) {
      query = query.not('public_url', 'is', null);
    }

    final response = await query.order('title').order('id').range(from, to);
    return [
      for (final row in response)
        StorageAsset.fromRow(Map<String, dynamic>.from(row)),
    ];
  }

  Future<List<StorageAsset>> getTestAssets() async {
    final response = await supabase
        .from('storage_assets')
        .select()
        .eq('is_test_asset', true)
        .eq('asset_type', 'snes_sealed')
        .not('public_url', 'is', null)
        .order('title')
        .limit(testAssetCount);

    return [
      for (final row in response)
        StorageAsset.fromRow(Map<String, dynamic>.from(row)),
    ];
  }

  Future<StorageAsset?> getAssetById(String id) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) return null;

    final response = await supabase
        .from('storage_assets')
        .select()
        .eq('id', normalizedId)
        .maybeSingle();
    return response == null
        ? null
        : StorageAsset.fromRow(Map<String, dynamic>.from(response));
  }
}

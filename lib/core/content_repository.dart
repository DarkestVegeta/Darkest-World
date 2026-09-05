import 'supabase_client.dart';

class ContentRepository {
  // Technical batch size. The UI decides how many items are visible.
  static const int pageSize = 36;

  Future<List<Map<String, dynamic>>> getContentPage({
    String? type,
    int page = 0,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase.from('darkestworld_content').select();
    if (type != null) query = query.eq('content_type', type);

    final response = await query.order('title').order('id').range(from, to);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAssetPage({
    String? assetType,
    int page = 0,
  }) async {
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

  Future<List<Map<String, dynamic>>> getContent({String? type}) {
    return getContentPage(type: type, page: 0);
  }

  Future<List<Map<String, dynamic>>> getAssets({String? assetType}) {
    return getAssetPage(assetType: assetType, page: 0);
  }
}

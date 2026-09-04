import 'supabase_client.dart';

class ContentRepository {
  static const int pageSize = 30;

  Future<List<Map<String, dynamic>>> getContentPage({
    String? type,
    int page = 0,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase
        .from('darkestworld_content')
        .select();

    final response = type == null
        ? await query.order('title').range(from, to)
        : await query
            .eq('content_type', type)
            .order('title')
            .range(from, to);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAssetPage({
    String? assetType,
    int page = 0,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase
        .from('storage_assets')
        .select();

    final response = assetType == null
        ? await query.order('title').range(from, to)
        : await query
            .eq('asset_type', assetType)
            .order('title')
            .range(from, to);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getContent({String? type}) async {
    return getContentPage(type: type, page: 0);
  }

  Future<List<Map<String, dynamic>>> getAssets({String? assetType}) async {
    return getAssetPage(assetType: assetType, page: 0);
  }
}

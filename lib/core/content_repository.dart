import 'supabase_client.dart';

class ContentRepository {
  Future<List<Map<String, dynamic>>> getContent({String? type}) async {
    final query = supabase.from('darkestworld_content').select();
    final response = type == null
        ? await query.order('title')
        : await query.eq('content_type', type).order('title');

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getAssets({String? assetType}) async {
    final query = supabase.from('storage_assets').select();
    final response = assetType == null
        ? await query.order('title')
        : await query.eq('asset_type', assetType).order('title');

    return List<Map<String, dynamic>>.from(response);
  }
}

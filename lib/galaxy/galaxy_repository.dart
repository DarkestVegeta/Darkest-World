import 'galaxy_node.dart';
import '../core/supabase_client.dart';

class GalaxyRepository {
  Future<List<GalaxyNode>> loadActiveNodes() async {
    final response = await supabase
        .from('darkestworld_galaxy_nodes')
        .select(
          'id,parent_id,node_type,node_key,title,position_x,position_y,position_z,'
          'radius,lod_policy,asset_manifest',
        )
        .eq('is_active', true)
        .order('sort_order')
        .order('node_type')
        .order('title');

    return [
      for (final row in response)
        GalaxyNode.fromMap(Map<String, dynamic>.from(row)),
    ];
  }
}

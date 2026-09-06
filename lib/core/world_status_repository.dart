import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_client.dart';

class WorldStatus {
  final int sections;
  final int assets;
  final int snesAssets;
  final int publicAssets;
  final int content;
  final int relations;
  final int timeline;

  const WorldStatus({
    required this.sections,
    required this.assets,
    required this.snesAssets,
    required this.publicAssets,
    required this.content,
    required this.relations,
    required this.timeline,
  });
}

class WorldStatusRepository {
  Future<int> _count(PostgrestFilterBuilder<List<Map<String, dynamic>>> query) async {
    final response = await query.select('id').count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<WorldStatus> load() async {
    final results = await Future.wait<int>([
      _count(supabase.from('darkestworld_sections')),
      _count(supabase.from('storage_assets')),
      _count(
        supabase.from('storage_assets').eq('asset_type', 'snes_sealed'),
      ),
      _count(
        supabase.from('storage_assets').not('public_url', 'is', null),
      ),
      _count(supabase.from('darkestworld_content')),
      _count(supabase.from('darkestworld_content_relations')),
      _count(supabase.from('darkestworld_timeline')),
    ]);

    return WorldStatus(
      sections: results[0],
      assets: results[1],
      snesAssets: results[2],
      publicAssets: results[3],
      content: results[4],
      relations: results[5],
      timeline: results[6],
    );
  }
}

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
  Future<WorldStatus> load() async {
    final results = await Future.wait([
      supabase.from('darkestworld_sections').select('id'),
      supabase.from('storage_assets').select('id'),
      supabase.from('storage_assets').select('id').eq('asset_type', 'snes_sealed'),
      supabase.from('storage_assets').select('id').not('public_url', 'is', null),
      supabase.from('darkestworld_content').select('id'),
      supabase.from('darkestworld_content_relations').select('id'),
      supabase.from('darkestworld_timeline').select('id'),
    ]);

    return WorldStatus(
      sections: (results[0] as List).length,
      assets: (results[1] as List).length,
      snesAssets: (results[2] as List).length,
      publicAssets: (results[3] as List).length,
      content: (results[4] as List).length,
      relations: (results[5] as List).length,
      timeline: (results[6] as List).length,
    );
  }
}

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
  Future<WorldStatus> load() async {
    final results = await Future.wait<int>([
      _countSections(),
      _countAssets(),
      _countSnesAssets(),
      _countPublicAssets(),
      _countContent(),
      _countRelations(),
      _countTimeline(),
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

  Future<int> _countSections() async {
    final response = await supabase
        .from('darkestworld_sections')
        .select('id')
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> _countAssets() async {
    final response = await supabase
        .from('storage_assets')
        .select('id')
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> _countSnesAssets() async {
    final response = await supabase
        .from('storage_assets')
        .select('id')
        .eq('asset_type', 'snes_sealed')
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> _countPublicAssets() async {
    final response = await supabase
        .from('storage_assets')
        .select('id')
        .not('public_url', 'is', null)
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> _countContent() async {
    final response = await supabase
        .from('darkestworld_content')
        .select('id')
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> _countRelations() async {
    final response = await supabase
        .from('darkestworld_content_relations')
        .select('id')
        .count(CountOption.exact);
    return response.count ?? 0;
  }

  Future<int> _countTimeline() async {
    final response = await supabase
        .from('darkestworld_timeline')
        .select('id')
        .count(CountOption.exact);
    return response.count ?? 0;
  }
}

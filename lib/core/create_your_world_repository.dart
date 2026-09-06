import 'supabase_client.dart';

class CreateYourWorldSystem {
  final String id;
  final String featureName;
  final String status;
  final String description;
  final bool soulPointsEnabled;
  final bool loreEnabled;
  final bool worldUnlocksEnabled;
  final bool visibleLockedAreasEnabled;
  final DateTime createdAt;

  const CreateYourWorldSystem({
    required this.id,
    required this.featureName,
    required this.status,
    required this.description,
    required this.soulPointsEnabled,
    required this.loreEnabled,
    required this.worldUnlocksEnabled,
    required this.visibleLockedAreasEnabled,
    required this.createdAt,
  });

  factory CreateYourWorldSystem.fromMap(Map<String, dynamic> row) {
    final id = _requiredText(row['id'], 'id');
    final featureName = _requiredText(row['feature_name'], 'feature_name');
    final status = _requiredText(row['status'], 'status');
    final description = _requiredText(row['description'], 'description');
    final createdAtText = _requiredText(row['created_at'], 'created_at');
    final createdAt = DateTime.tryParse(createdAtText);
    if (createdAt == null) {
      throw FormatException('Invalid Create Your World timestamp: $createdAtText');
    }

    return CreateYourWorldSystem(
      id: id,
      featureName: featureName,
      status: status,
      description: description,
      soulPointsEnabled: _requiredBool(row['soul_points_enabled'], 'soul_points_enabled'),
      loreEnabled: _requiredBool(row['lore_enabled'], 'lore_enabled'),
      worldUnlocksEnabled: _requiredBool(row['world_unlocks_enabled'], 'world_unlocks_enabled'),
      visibleLockedAreasEnabled: _requiredBool(
        row['visible_locked_areas_enabled'],
        'visible_locked_areas_enabled',
      ),
      createdAt: createdAt,
    );
  }

  static String _requiredText(Object? value, String field) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) {
      throw FormatException('Missing required Create Your World field: $field');
    }
    return text;
  }

  static bool _requiredBool(Object? value, String field) {
    if (value is bool) return value;
    throw FormatException('Invalid Create Your World boolean field: $field');
  }
}

class CreateYourWorldRepository {
  Future<CreateYourWorldSystem> load() async {
    final response = await supabase
        .from('create_your_world_system')
        .select()
        .eq('feature_name', 'Create Your World')
        .limit(1);

    if (response.isEmpty) {
      throw StateError('Create Your World system configuration was not found.');
    }

    return CreateYourWorldSystem.fromMap(
      Map<String, dynamic>.from(response.first),
    );
  }
}

/// Shared foundation contracts for systems that are prepared now and expanded later.
enum FoundationStatus { prepared, hold, active }

enum ScanConfidence { low, medium, high }

enum NotificationKind { system, social, world, moderation, gameplay }

enum PresenceState { offline, online, away, reconnecting }

enum WorldRuleScope { galaxy, planet, world, area, object }

class RelationRef {
  final String fromId;
  final String toId;
  final String relationType;
  final Map<String, Object?> metadata;
  const RelationRef({required this.fromId, required this.toId, required this.relationType, this.metadata = const {}});
}

class ScannerResult {
  final String scanId;
  final String? entityId;
  final String? entityType;
  final ScanConfidence confidence;
  final Map<String, Object?> evidence;
  const ScannerResult({required this.scanId, this.entityId, this.entityType, required this.confidence, this.evidence = const {}});
}

class WeatherSnapshot {
  final String provider;
  final String locationKey;
  final DateTime observedAt;
  final DateTime expiresAt;
  final double? temperatureC;
  final String? condition;
  const WeatherSnapshot({required this.provider, required this.locationKey, required this.observedAt, required this.expiresAt, this.temperatureC, this.condition});
}

class NotificationEnvelope {
  final String id;
  final String recipientId;
  final NotificationKind kind;
  final String title;
  final String? body;
  final Map<String, Object?> payload;
  final DateTime createdAt;
  const NotificationEnvelope({required this.id, required this.recipientId, required this.kind, required this.title, this.body, this.payload = const {}, required this.createdAt});
}

class MultiplayerRoomRef {
  final String roomId;
  final String gameKey;
  final String status;
  final PresenceState localPresence;
  const MultiplayerRoomRef({required this.roomId, required this.gameKey, required this.status, required this.localPresence});
}

class DynamicWorldRule {
  final String ruleId;
  final WorldRuleScope scope;
  final String key;
  final Map<String, Object?> conditions;
  final Map<String, Object?> effects;
  final bool active;
  const DynamicWorldRule({required this.ruleId, required this.scope, required this.key, required this.conditions, required this.effects, required this.active});
}

/// Future systems stay technically represented here while their full UX/gameplay remains on HOLD.
const darkestWorldFoundationKeys = <String>[
  'users_profiles_permissions',
  'collections_achievements_discoveries',
  'create_your_world',
  'admin',
  'global',
  'search',
  'connections_relations',
  'notifications',
  'weather',
  'dynamic_worlds',
  'scanner_discovery',
  'multiplayer_chess_tetris',
  'subscription_readiness',
  'observability',
  'backup_security',
];

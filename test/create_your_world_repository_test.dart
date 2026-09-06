import 'package:flutter_test/flutter_test.dart';

import 'package:darkest_world/core/create_your_world_repository.dart';

void main() {
  group('CreateYourWorldSystem.fromMap', () {
    test('parses a complete construction configuration', () {
      final system = CreateYourWorldSystem.fromMap({
        'id': 'system-1',
        'feature_name': 'Create Your World',
        'status': 'construction',
        'description': 'Personal world construction.',
        'soul_points_enabled': false,
        'lore_enabled': true,
        'world_unlocks_enabled': true,
        'visible_locked_areas_enabled': true,
        'created_at': '2026-08-30T18:12:06.38259Z',
      });

      expect(system.featureName, 'Create Your World');
      expect(system.status, 'construction');
      expect(system.soulPointsEnabled, isFalse);
      expect(system.loreEnabled, isTrue);
      expect(system.worldUnlocksEnabled, isTrue);
      expect(system.visibleLockedAreasEnabled, isTrue);
    });

    test('rejects missing required text fields', () {
      expect(
        () => CreateYourWorldSystem.fromMap({
          'id': 'system-1',
          'feature_name': '',
          'status': 'construction',
          'description': 'Personal world construction.',
          'soul_points_enabled': false,
          'lore_enabled': false,
          'world_unlocks_enabled': false,
          'visible_locked_areas_enabled': false,
          'created_at': '2026-08-30T18:12:06Z',
        }),
        throwsFormatException,
      );
    });

    test('rejects malformed booleans', () {
      expect(
        () => CreateYourWorldSystem.fromMap({
          'id': 'system-1',
          'feature_name': 'Create Your World',
          'status': 'construction',
          'description': 'Personal world construction.',
          'soul_points_enabled': 'false',
          'lore_enabled': false,
          'world_unlocks_enabled': false,
          'visible_locked_areas_enabled': false,
          'created_at': '2026-08-30T18:12:06Z',
        }),
        throwsFormatException,
      );
    });

    test('rejects malformed timestamps', () {
      expect(
        () => CreateYourWorldSystem.fromMap({
          'id': 'system-1',
          'feature_name': 'Create Your World',
          'status': 'construction',
          'description': 'Personal world construction.',
          'soul_points_enabled': false,
          'lore_enabled': false,
          'world_unlocks_enabled': false,
          'visible_locked_areas_enabled': false,
          'created_at': 'not-a-date',
        }),
        throwsFormatException,
      );
    });
  });
}

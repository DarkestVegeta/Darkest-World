import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/content_repository.dart';

Map<String, dynamic> item(
  String id,
  String title,
  String date, {
  String? source,
  String? externalId,
}) => {
  'id': id,
  'title': title,
  'release_date': date,
  if (source != null) 'external_source': source,
  if (externalId != null) 'external_id': externalId,
};

void main() {
  group('ContentRepository franchise navigation', () {
    test('uses release date, title, and id as deterministic fallback ordering', () {
      final current = item('2', 'Second', '2001-01-01');
      final navigation = ContentRepository.buildFranchiseNavigation(
        current: current,
        content: [
          item('3', 'Third', '2002-01-01'),
          current,
          item('1', 'First', '2000-01-01'),
        ],
        timeline: const [],
      );

      expect(navigation?.previous?['id'], '1');
      expect(navigation?.current['id'], '2');
      expect(navigation?.next?['id'], '3');
    });

    test('keeps missing release dates after dated content like the database order', () {
      final current = item('2', 'Second', '2001-01-01');
      final navigation = ContentRepository.buildFranchiseNavigation(
        current: current,
        content: [
          {'id': '4', 'title': 'Undated', 'release_date': null},
          current,
          item('1', 'First', '2000-01-01'),
        ],
        timeline: const [],
      );

      expect(navigation?.previous?['id'], '1');
      expect(navigation?.next?['id'], '4');
    });

    test('uses timeline order when the timeline identifies the current item', () {
      final first = item('1', 'First', '2000-01-01', source: 'igdb', externalId: 'a');
      final current = item('2', 'Current', '2001-01-01', source: 'igdb', externalId: 'b');
      final third = item('3', 'Third', '2002-01-01', source: 'igdb', externalId: 'c');

      final navigation = ContentRepository.buildFranchiseNavigation(
        current: current,
        content: [first, current, third],
        timeline: [
          {'external_source': 'igdb', 'external_id': 'c'},
          {'external_source': 'igdb', 'external_id': 'b'},
          {'external_source': 'igdb', 'external_id': 'a'},
        ],
      );

      expect(navigation?.previous?['id'], '3');
      expect(navigation?.current['id'], '2');
      expect(navigation?.next?['id'], '1');
    });

    test('falls back when a timeline exists but does not contain the current item', () {
      final current = item('2', 'Second', '2001-01-01', source: 'igdb', externalId: 'b');
      final first = item('1', 'First', '2000-01-01', source: 'igdb', externalId: 'a');
      final third = item('3', 'Third', '2002-01-01', source: 'igdb', externalId: 'c');

      final navigation = ContentRepository.buildFranchiseNavigation(
        current: current,
        content: [first, current, third],
        timeline: [
          {'external_source': 'igdb', 'external_id': 'a'},
          {'external_source': 'igdb', 'external_id': 'c'},
        ],
      );

      expect(navigation?.previous?['id'], '1');
      expect(navigation?.next?['id'], '3');
    });

    test('rejects a current item without an id', () {
      final navigation = ContentRepository.buildFranchiseNavigation(
        current: {'title': 'Broken'},
        content: const [],
        timeline: const [],
      );

      expect(navigation, isNull);
    });
  });
}

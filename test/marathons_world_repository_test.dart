import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/marathons_world_repository.dart';

void main() {
  test('parses a complete marathon row', () {
    final marathon = WorldMarathon.fromMap({
      'id': 'marathon-1',
      'title': 'Zelda-thon',
      'slug': 'zelda-thon',
      'description': 'Play the Zelda franchise marathon.',
      'status': 'planned',
      'starts_at': '2026-10-01T18:00:00Z',
      'ends_at': '2026-10-02T02:00:00Z',
    });

    expect(marathon.id, 'marathon-1');
    expect(marathon.title, 'Zelda-thon');
    expect(marathon.slug, 'zelda-thon');
    expect(marathon.description, 'Play the Zelda franchise marathon.');
    expect(marathon.status, 'planned');
    expect(marathon.startsAt, DateTime.parse('2026-10-01T18:00:00Z'));
    expect(marathon.endsAt, DateTime.parse('2026-10-02T02:00:00Z'));
  });

  test('allows optional marathon fields to be empty', () {
    final marathon = WorldMarathon.fromMap({
      'id': 'marathon-2',
      'title': 'Open marathon',
      'slug': 'open-marathon',
      'description': null,
      'status': null,
      'starts_at': null,
      'ends_at': '',
    });

    expect(marathon.description, '');
    expect(marathon.status, '');
    expect(marathon.startsAt, isNull);
    expect(marathon.endsAt, isNull);
  });

  test('rejects missing required marathon fields', () {
    expect(
      () => WorldMarathon.fromMap({'id': null, 'title': null, 'slug': null}),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects malformed optional marathon dates', () {
    expect(
      () => WorldMarathon.fromMap({
        'id': 'marathon-3',
        'title': 'Broken marathon',
        'slug': 'broken-marathon',
        'starts_at': 'not-a-date',
      }),
      throwsA(isA<FormatException>()),
    );
  });
}

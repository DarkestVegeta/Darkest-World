import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/events_world_repository.dart';

void main() {
  test('parses a complete event row', () {
    final event = WorldEvent.fromMap({
      'id': 'event-1',
      'title': 'Darkest Event',
      'slug': 'darkest-event',
      'description': 'A community event.',
      'starts_at': '2026-09-10T18:30:00Z',
      'ends_at': '2026-09-10T21:00:00Z',
      'location': 'Darkest-World',
    });

    expect(event.id, 'event-1');
    expect(event.title, 'Darkest Event');
    expect(event.slug, 'darkest-event');
    expect(event.description, 'A community event.');
    expect(event.startsAt, DateTime.parse('2026-09-10T18:30:00Z'));
    expect(event.endsAt, DateTime.parse('2026-09-10T21:00:00Z'));
    expect(event.location, 'Darkest-World');
  });

  test('allows optional event fields to be empty', () {
    final event = WorldEvent.fromMap({
      'id': 'event-2',
      'title': 'Open Event',
      'slug': 'open-event',
      'description': null,
      'starts_at': null,
      'ends_at': '',
      'location': null,
    });

    expect(event.description, '');
    expect(event.startsAt, isNull);
    expect(event.endsAt, isNull);
    expect(event.location, '');
  });

  test('rejects missing required event fields', () {
    expect(
      () => WorldEvent.fromMap({
        'id': null,
        'title': null,
        'slug': null,
      }),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects malformed optional dates', () {
    expect(
      () => WorldEvent.fromMap({
        'id': 'event-3',
        'title': 'Broken Event',
        'slug': 'broken-event',
        'starts_at': 'not-a-date',
      }),
      throwsA(isA<FormatException>()),
    );
  });
}

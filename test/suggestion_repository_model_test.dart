import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/suggestion_repository.dart';

void main() {
  test('normalizes stored suggestion identity fields', () {
    final suggestion = WorldSuggestion.fromMap({
      'id': ' suggestion-1 ',
      'source': ' igdb ',
      'content_type': ' game ',
      'external_id': ' 12345 ',
      'title': ' Test Game ',
      'image_url': ' https://example.com/game.jpg ',
      'soul_points': 25,
      'status': ' pending ',
      'submitted_by': ' user-1 ',
      'submitted_at': '2026-09-05T00:00:00Z',
    });

    expect(suggestion.id, 'suggestion-1');
    expect(suggestion.source, 'igdb');
    expect(suggestion.contentType, 'game');
    expect(suggestion.externalId, '12345');
    expect(suggestion.title, 'Test Game');
    expect(suggestion.imageUrl, 'https://example.com/game.jpg');
    expect(suggestion.status, 'pending');
    expect(suggestion.submittedBy, 'user-1');
  });

  test('keeps a missing suggestion image nullable and defaults missing soul points to zero', () {
    final suggestion = WorldSuggestion.fromMap({
      'id': 'suggestion-2',
      'source': 'tmdb',
      'content_type': 'movie',
      'external_id': '67890',
      'title': 'Test Movie',
      'image_url': null,
      'soul_points': null,
      'status': 'later',
      'submitted_by': 'user-2',
      'submitted_at': '2026-09-05T00:00:00Z',
    });

    expect(suggestion.imageUrl, isNull);
    expect(suggestion.soulPoints, 0);
  });

  test('rejects malformed required suggestion identity fields', () {
    final fields = <String, String>{
      'id': 'id',
      'source': 'source',
      'content_type': 'content type',
      'external_id': 'external id',
      'title': 'title',
      'status': 'status',
      'submitted_by': 'submitted by',
    };

    for (final entry in fields.entries) {
      final row = <String, dynamic>{
        'id': 'suggestion-1',
        'source': 'igdb',
        'content_type': 'game',
        'external_id': '12345',
        'title': 'Test Game',
        'image_url': null,
        'soul_points': 0,
        'status': 'pending',
        'submitted_by': 'user-1',
        'submitted_at': '2026-09-05T00:00:00Z',
      };
      row[entry.key] = '   ';
      expect(
        () => WorldSuggestion.fromMap(row),
        throwsA(isA<FormatException>()),
        reason: 'blank ${entry.key} must be rejected',
      );
    }
  });

  test('documents the repository input allowlists', () {
    expect(SuggestionRepository.allowedSources, containsAll(['igdb', 'tmdb']));
    expect(
      SuggestionRepository.allowedContentTypes,
      containsAll(['game', 'movie', 'series']),
    );
  });
}

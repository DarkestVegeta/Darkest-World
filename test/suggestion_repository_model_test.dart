import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/suggestion_repository.dart';

void main() {
  test('parses a stored suggestion row without changing its data contract', () {
    final suggestion = WorldSuggestion.fromMap({
      'id': 'suggestion-1',
      'source': 'igdb',
      'content_type': 'game',
      'external_id': '12345',
      'title': 'Test Game',
      'image_url': 'https://example.com/game.jpg',
      'soul_points': 25,
      'status': 'pending',
      'submitted_by': 'user-1',
      'submitted_at': '2026-09-05T00:00:00Z',
    });

    expect(suggestion.id, 'suggestion-1');
    expect(suggestion.source, 'igdb');
    expect(suggestion.contentType, 'game');
    expect(suggestion.externalId, '12345');
    expect(suggestion.title, 'Test Game');
    expect(suggestion.imageUrl, 'https://example.com/game.jpg');
    expect(suggestion.soulPoints, 25);
    expect(suggestion.status, 'pending');
    expect(suggestion.submittedBy, 'user-1');
    expect(suggestion.submittedAt, DateTime.parse('2026-09-05T00:00:00Z'));
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

  test('documents the repository input allowlists', () {
    expect(SuggestionRepository.allowedSources, containsAll(['igdb', 'tmdb']));
    expect(
      SuggestionRepository.allowedContentTypes,
      containsAll(['game', 'movie', 'series']),
    );
  });
}

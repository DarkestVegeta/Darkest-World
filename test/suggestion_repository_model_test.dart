import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/suggestion_repository.dart';

void main() {
  Map<String, dynamic> validRow() => {
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

  test('normalizes stored suggestion identity fields', () {
    final suggestion = WorldSuggestion.fromMap({...validRow(), 'id': ' suggestion-1 ', 'source': ' igdb ', 'content_type': ' game ', 'external_id': ' 12345 ', 'title': ' Test Game ', 'image_url': ' https://example.com/game.jpg ', 'soul_points': 25, 'status': ' pending ', 'submitted_by': ' user-1 '});
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
    final suggestion = WorldSuggestion.fromMap({...validRow(), 'soul_points': null});
    expect(suggestion.imageUrl, isNull);
    expect(suggestion.soulPoints, 0);
  });

  test('rejects malformed required suggestion identity fields', () {
    for (final key in ['id','source','content_type','external_id','title','status','submitted_by']) {
      final row = validRow()..[key] = '   ';
      expect(() => WorldSuggestion.fromMap(row), throwsA(isA<FormatException>()));
    }
  });

  test('rejects malformed suggestion timestamps', () {
    final row = validRow()..['submitted_at'] = 'not-a-timestamp';
    expect(() => WorldSuggestion.fromMap(row), throwsA(isA<FormatException>()));
  });

  test('rejects missing or blank suggestion timestamps', () {
    for (final value in [null, '   ']) {
      final row = validRow()..['submitted_at'] = value;
      expect(() => WorldSuggestion.fromMap(row), throwsA(isA<FormatException>()));
    }
  });

  test('rejects malformed soul points values', () {
    for (final value in ['25', <int>[25], Object()]) {
      final row = validRow()..['soul_points'] = value;
      expect(() => WorldSuggestion.fromMap(row), throwsA(isA<FormatException>()));
    }
  });

  test('documents the repository input allowlists', () {
    expect(SuggestionRepository.allowedSources, containsAll(['igdb', 'tmdb']));
    expect(SuggestionRepository.allowedContentTypes, containsAll(['game', 'movie', 'series']));
  });

  test('parses a complete viewer game lookup result', () {
    final result = ViewerContentResult.fromMap({
      'external_source': 'igdb',
      'content_type': 'game',
      'external_id': '12345',
      'title': 'Test Game',
      'image_url': 'https://example.com/game.jpg',
      'release_date': '2026-01-02',
      'description': 'A test game.',
    });

    expect(result.source, 'igdb');
    expect(result.contentType, 'game');
    expect(result.externalId, '12345');
    expect(result.title, 'Test Game');
    expect(result.imageUrl, 'https://example.com/game.jpg');
    expect(result.releaseDate, '2026-01-02');
    expect(result.description, 'A test game.');
  });

  test('parses a complete viewer TMDB result using source fallback', () {
    final result = ViewerContentResult.fromMap({
      'source': 'tmdb',
      'content_type': 'series',
      'external_id': '67890',
      'title': 'Test Series',
      'image_url': null,
      'release_date': null,
      'description': null,
    });

    expect(result.source, 'tmdb');
    expect(result.contentType, 'series');
    expect(result.externalId, '67890');
    expect(result.title, 'Test Series');
    expect(result.imageUrl, isNull);
    expect(result.releaseDate, isNull);
    expect(result.description, isNull);
  });

  test('rejects incomplete viewer lookup results', () {
    final base = <String, dynamic>{
      'external_source': 'igdb',
      'content_type': 'game',
      'external_id': '12345',
      'title': 'Test Game',
    };

    for (final key in ['external_source', 'content_type', 'external_id', 'title']) {
      final row = {...base, key: '   '};
      expect(() => ViewerContentResult.fromMap(row), throwsA(isA<FormatException>()));
    }
  });

  test('returns no viewer lookup results for a blank query without calling the network', () async {
    final results = await SuggestionRepository().searchViewerContent(
      source: 'igdb',
      contentType: 'game',
      query: '   ',
    );
    expect(results, isEmpty);
  });

  test('rejects unsupported viewer lookup sources before calling the network', () async {
    expect(
      () => SuggestionRepository().searchViewerContent(
        source: 'other',
        contentType: 'game',
        query: 'Halo',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('rejects unsupported viewer lookup content types before calling the network', () async {
    expect(
      () => SuggestionRepository().searchViewerContent(
        source: 'igdb',
        contentType: 'movie',
        query: 'Halo',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('rejects mismatched viewer lookup source and content type before calling the network', () async {
    expect(
      () => SuggestionRepository().searchViewerContent(
        source: 'tmdb',
        contentType: 'game',
        query: 'Halo',
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}

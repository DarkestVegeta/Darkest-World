import 'package:darkest_world/core/chat_repository.dart';
import 'package:darkest_world/core/chat_scope.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> validRow({
  Object? id = 'msg-1',
  Object? message = 'Hello',
  Object? scope = 'games',
  Object? createdAt = '2026-09-05T10:00:00Z',
}) {
  return {
    'id': id,
    'author_id': 'user-1',
    'message': message,
    'chat_scope': scope,
    'content_id': 'content-1',
    'marathon_id': null,
    'created_at': createdAt,
  };
}

void main() {
  test('ChatMessage trims required and optional text fields', () {
    final message = ChatMessage.fromMap({
      ...validRow(),
      'id': '  msg-1  ',
      'message': '  Hello  ',
      'author_id': '  user-1  ',
      'content_id': '  content-1  ',
    });

    expect(message.id, 'msg-1');
    expect(message.message, 'Hello');
    expect(message.scope, ChatScope.games);
    expect(message.authorId, 'user-1');
    expect(message.contentId, 'content-1');
  });

  test('ChatMessage rejects missing required identity fields', () {
    for (final field in ['id', 'message', 'chat_scope', 'created_at']) {
      expect(
        () => ChatMessage.fromMap(validRow()..[field] = '   '),
        throwsFormatException,
        reason: field,
      );
    }
  });

  test('ChatMessage rejects unknown chat scope instead of falling back', () {
    expect(
      () => ChatMessage.fromMap(validRow(scope: 'not-a-scope')),
      throwsFormatException,
    );
  });

  test('ChatMessage rejects malformed timestamps', () {
    expect(
      () => ChatMessage.fromMap(validRow(createdAt: 'not-a-date')),
      throwsFormatException,
    );
  });

  test('ChatMessage normalizes blank optional ids to null', () {
    final message = ChatMessage.fromMap({
      ...validRow(),
      'author_id': '  ',
      'content_id': '  ',
      'marathon_id': null,
    });

    expect(message.authorId, isNull);
    expect(message.contentId, isNull);
    expect(message.marathonId, isNull);
  });
}

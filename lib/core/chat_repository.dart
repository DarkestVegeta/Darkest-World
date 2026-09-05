import 'package:supabase_flutter/supabase_flutter.dart';

import 'chat_scope.dart';
import 'supabase_client.dart';

class ChatMessage {
  final String id;
  final String? authorId;
  final String message;
  final ChatScope scope;
  final String? contentId;
  final String? marathonId;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.authorId,
    required this.message,
    required this.scope,
    required this.contentId,
    required this.marathonId,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> row) {
    return ChatMessage(
      id: '${row['id']}',
      authorId: row['author_id']?.toString(),
      message: '${row['message']}',
      scope: ChatScope.values.firstWhere(
        (value) => value.name == '${row['chat_scope']}',
        orElse: () => ChatScope.games,
      ),
      contentId: row['content_id']?.toString(),
      marathonId: row['marathon_id']?.toString(),
      createdAt: DateTime.parse('${row['created_at']}'),
    );
  }
}

class ChatRepository {
  Future<List<ChatMessage>> getMessages({
    required ChatScope scope,
    String? contentId,
    String? marathonId,
    int limit = 100,
  }) async {
    if (limit < 1 || limit > 200) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 200.');
    }

    var query = supabase
        .from('darkestworld_chat_messages')
        .select()
        .eq('chat_scope', scope.name);

    if (contentId != null) {
      query = query.eq('content_id', contentId);
    } else {
      query = query.isFilter('content_id', null);
    }

    if (marathonId != null) {
      query = query.eq('marathon_id', marathonId);
    } else {
      query = query.isFilter('marathon_id', null);
    }

    final response = await query.order('created_at').limit(limit);
    return [
      for (final row in response)
        ChatMessage.fromMap(Map<String, dynamic>.from(row)),
    ];
  }

  Stream<List<ChatMessage>> streamMessages({
    required ChatScope scope,
    String? contentId,
    String? marathonId,
    int limit = 100,
  }) {
    if (limit < 1 || limit > 200) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 200.');
    }

    var stream = supabase
        .from('darkestworld_chat_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_scope', scope.name);

    if (contentId != null) {
      stream = stream.eq('content_id', contentId);
    } else {
      stream = stream.isFilter('content_id', null);
    }

    if (marathonId != null) {
      stream = stream.eq('marathon_id', marathonId);
    } else {
      stream = stream.isFilter('marathon_id', null);
    }

    return stream.order('created_at').limit(limit).map(
          (rows) => [
            for (final row in rows)
              ChatMessage.fromMap(Map<String, dynamic>.from(row)),
          ],
        );
  }

  Future<void> sendMessage({
    required ChatContext context,
    required String message,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw AuthException('Je moet ingelogd zijn om te chatten.');
    }

    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(message, 'message', 'Bericht mag niet leeg zijn.');
    }
    if (trimmed.length > 2000) {
      throw ArgumentError.value(
        message,
        'message',
        'Een bericht mag maximaal 2000 tekens bevatten.',
      );
    }
    if (!context.isAvailable) {
      throw StateError('Marathon Chat is momenteel niet actief.');
    }

    await supabase.from('darkestworld_chat_messages').insert({
      'author_id': user.id,
      'message': trimmed,
      'chat_scope': context.scope.name,
      'content_id': context.scope == ChatScope.marathon
          ? null
          : context.contentId,
      'marathon_id': context.scope == ChatScope.marathon
          ? context.contentId
          : null,
    });
  }
}

import 'chat_scope.dart';
import 'supabase_client.dart';

class ChatSearchResult {
  final String title;
  final String subtitle;
  final String? contentId;

  const ChatSearchResult({
    required this.title,
    required this.subtitle,
    this.contentId,
  });
}

class ChatSearchRepository {
  Future<List<ChatSearchResult>> search({
    required ChatScope scope,
    required String query,
    String? contentId,
    int limit = 24,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return [];
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', 'Must be between 1 and 100.');
    }

    if (scope == ChatScope.music || scope == ChatScope.marathon) {
      return _searchMessages(scope, normalized, contentId: contentId, limit: limit);
    }

    final safe = normalized
        .replaceAll(RegExp(r"[,()]"), ' ')
        .replaceAll("'", ' ');
    var request = supabase
        .from('darkestworld_content')
        .select('id, title, franchise, content_type')
        .eq('content_type', _contentTypeFor(scope));

    request = request.or('title.ilike.%$safe%,franchise.ilike.%$safe%');

    final response = await request
        .order('title')
        .order('id')
        .limit(limit);

    return [
      for (final row in response)
        ChatSearchResult(
          title: '${row['title'] ?? 'Untitled'}',
          subtitle: '${row['franchise'] ?? ''}'.trim(),
          contentId: '${row['id']}',
        ),
    ];
  }

  Future<List<ChatSearchResult>> _searchMessages(
    ChatScope scope,
    String query, {
    String? contentId,
    required int limit,
  }) async {
    var request = supabase
        .from('darkestworld_chat_messages')
        .select('id, message, content_id, marathon_id, created_at')
        .eq('chat_scope', scope.name)
        .ilike('message', '%$query%');

    if (scope == ChatScope.marathon) {
      if (contentId == null) {
        request = request.isFilter('marathon_id', null);
      } else {
        request = request.eq('marathon_id', contentId);
      }
    } else {
      request = request.isFilter('content_id', null);
      request = request.isFilter('marathon_id', null);
    }

    final response = await request.order('created_at', ascending: false).limit(limit);

    return [
      for (final row in response)
        ChatSearchResult(
          title: '${row['message'] ?? ''}',
          subtitle: 'Chatbericht',
          contentId: row['content_id']?.toString(),
        ),
    ];
  }

  String _contentTypeFor(ChatScope scope) {
    switch (scope) {
      case ChatScope.games:
        return 'game';
      case ChatScope.movies:
        return 'movie';
      case ChatScope.series:
        return 'series';
      case ChatScope.music:
      case ChatScope.marathon:
        throw ArgumentError('This scope does not map to content.');
    }
  }
}

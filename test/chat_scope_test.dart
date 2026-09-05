import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/chat_scope.dart';

void main() {
  test('world chat access stays scoped to the relevant world', () {
    expect(ChatAccessPolicy.scopeForWorldSlug('game-world'), ChatScope.games);
    expect(ChatAccessPolicy.scopeForWorldSlug('cinema-world'), ChatScope.movies);
    expect(ChatAccessPolicy.scopeForWorldSlug('series-world'), ChatScope.series);
    expect(ChatAccessPolicy.scopeForWorldSlug('music-world'), ChatScope.music);
    expect(ChatAccessPolicy.scopeForWorldSlug('dark-core'), isNull);
  });

  test('fullscreen chat exposes only chat worlds and active marathon chat', () {
    expect(
      ChatAccessPolicy.allowedScopesForFullscreen(),
      [ChatScope.games, ChatScope.movies, ChatScope.series, ChatScope.music],
    );
    expect(
      ChatAccessPolicy.allowedScopesForFullscreen(marathonChatActive: true),
      [
        ChatScope.games,
        ChatScope.movies,
        ChatScope.series,
        ChatScope.music,
        ChatScope.marathon,
      ],
    );
  });

  test('marathon chat depends on chat presence, not streaming status', () {
    expect(
      const ChatContext(scope: ChatScope.marathon).isAvailable,
      isFalse,
    );
    expect(
      const ChatContext(
        scope: ChatScope.marathon,
        marathonChatActive: true,
      ).isAvailable,
      isTrue,
    );
  });
}

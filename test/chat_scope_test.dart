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

  test('fullscreen chat exposes only chat worlds and marathon when live', () {
    expect(
      ChatAccessPolicy.allowedScopesForFullscreen(),
      [ChatScope.games, ChatScope.movies, ChatScope.series, ChatScope.music],
    );
    expect(
      ChatAccessPolicy.allowedScopesForFullscreen(marathonLive: true),
      [
        ChatScope.games,
        ChatScope.movies,
        ChatScope.series,
        ChatScope.music,
        ChatScope.marathon,
      ],
    );
  });

  test('marathon chat is unavailable unless the marathon is live', () {
    expect(
      const ChatContext(scope: ChatScope.marathon).isAvailable,
      isFalse,
    );
    expect(
      const ChatContext(scope: ChatScope.marathon, marathonLive: true)
          .isAvailable,
      isTrue,
    );
  });
}

enum ChatScope {
  games,
  movies,
  series,
  music,
  marathon,
}

class ChatContext {
  final ChatScope scope;
  final String? contentId;
  final String? contentTitle;
  final bool marathonLive;

  const ChatContext({
    required this.scope,
    this.contentId,
    this.contentTitle,
    this.marathonLive = false,
  });

  String get label {
    switch (scope) {
      case ChatScope.games:
        return 'Games Chat';
      case ChatScope.movies:
        return 'Movies Chat';
      case ChatScope.series:
        return 'Series Chat';
      case ChatScope.music:
        return 'Music Chat';
      case ChatScope.marathon:
        return 'Marathon Chat';
    }
  }

  bool get isAvailable => scope != ChatScope.marathon || marathonLive;
}

class ChatAccessPolicy {
  static ChatScope? scopeForWorldSlug(String slug) {
    switch (slug) {
      case 'game-world':
        return ChatScope.games;
      case 'cinema-world':
        return ChatScope.movies;
      case 'series-world':
        return ChatScope.series;
      case 'music-world':
        return ChatScope.music;
      default:
        return null;
    }
  }

  static List<ChatScope> allowedScopesForFullscreen({bool marathonLive = false}) {
    return [
      ChatScope.games,
      ChatScope.movies,
      ChatScope.series,
      ChatScope.music,
      if (marathonLive) ChatScope.marathon,
    ];
  }
}

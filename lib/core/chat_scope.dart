enum ChatScope {
  games,
  movies,
  series,
  music,
  marathon,
  chatbox,
}

class ChatContext {
  final ChatScope scope;
  final String? contentId;
  final String? contentTitle;
  final bool marathonChatActive;

  const ChatContext({
    required this.scope,
    this.contentId,
    this.contentTitle,
    this.marathonChatActive = false,
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
      case ChatScope.chatbox:
        return 'Chatbox';
    }
  }

  bool get isAvailable =>
      scope != ChatScope.marathon || marathonChatActive;
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
      case 'chatbox':
        return ChatScope.chatbox;
      default:
        return null;
    }
  }

  static List<ChatScope> allowedScopesForFullscreen({
    bool marathonChatActive = false,
  }) {
    return [
      ChatScope.games,
      ChatScope.movies,
      ChatScope.series,
      ChatScope.music,
      if (marathonChatActive) ChatScope.marathon,
    ];
  }
}

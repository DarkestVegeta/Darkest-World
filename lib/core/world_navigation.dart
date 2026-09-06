enum WorldDestination {
  gameContent,
  movieContent,
  seriesContent,
  music,
  chat,
  chatbox,
  events,
  marathons,
  socialMedia,
  createYourWorld,
  timeline,
  identityWorld,
  darkCore,
  basic,
}

class WorldNavigation {
  const WorldNavigation._();

  static WorldDestination destinationForSlug(String slug) {
    switch (slug) {
      case 'game-world':
        return WorldDestination.gameContent;
      case 'cinema-world':
        return WorldDestination.movieContent;
      case 'series-world':
        return WorldDestination.seriesContent;
      case 'music-world':
        return WorldDestination.music;
      case 'chat':
        return WorldDestination.chat;
      case 'chatbox':
        return WorldDestination.chatbox;
      case 'events':
        return WorldDestination.events;
      case 'marathons':
        return WorldDestination.marathons;
      case 'social-media':
        return WorldDestination.socialMedia;
      case 'create-your-world':
        return WorldDestination.createYourWorld;
      case 'timeline':
        return WorldDestination.timeline;
      case 'identity-world':
        return WorldDestination.identityWorld;
      case 'dark-core':
        return WorldDestination.darkCore;
      default:
        return WorldDestination.basic;
    }
  }
}

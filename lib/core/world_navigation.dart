enum WorldDestination {
  gameContent,
  movieContent,
  seriesContent,
  music,
  chat,
  events,
  marathons,
  socialMedia,
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
      case 'events':
        return WorldDestination.events;
      case 'marathons':
        return WorldDestination.marathons;
      case 'social-media':
        return WorldDestination.socialMedia;
      default:
        return WorldDestination.basic;
    }
  }
}

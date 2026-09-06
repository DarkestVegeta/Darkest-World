enum WorldDestination {
  gameContent,
  movieContent,
  seriesContent,
  music,
  chat,
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
      default:
        return WorldDestination.basic;
    }
  }
}

import 'galaxy_node.dart';

/// Navigation model for Game World.
///
/// The world remains the visual/immersive layer while the archive board provides
/// an immediate practical route into the same data. The two modes are intentionally
/// not separate datasets.
enum GameWorldNavigationMode {
  explore,
  archiveBoard,
  quickFind,
}

class GameWorldBoardItem {
  final String key;
  final String title;
  final String subtitle;
  final String? targetNodeKey;

  const GameWorldBoardItem({
    required this.key,
    required this.title,
    required this.subtitle,
    this.targetNodeKey,
  });

  Map<String, dynamic> toMap() => {
        'key': key,
        'title': title,
        'subtitle': subtitle,
        if (targetNodeKey != null) 'targetNodeKey': targetNodeKey,
      };
}

class GameWorldNavigationContract {
  static const defaultItems = <GameWorldBoardItem>[
    GameWorldBoardItem(
      key: 'nintendo',
      title: 'NINTENDO',
      subtitle: 'Explore Nintendo archives',
    ),
    GameWorldBoardItem(
      key: 'sega',
      title: 'SEGA',
      subtitle: 'Explore Sega Mega Drive and related archives',
    ),
    GameWorldBoardItem(
      key: 'playstation',
      title: 'PLAYSTATION',
      subtitle: 'Explore PlayStation archives',
    ),
    GameWorldBoardItem(
      key: 'xbox',
      title: 'XBOX',
      subtitle: 'Explore Xbox archives',
    ),
    GameWorldBoardItem(
      key: 'pc',
      title: 'PC',
      subtitle: 'Explore PC archives',
    ),
    GameWorldBoardItem(
      key: 'quick-find',
      title: 'QUICK FIND',
      subtitle: 'Search the archive directly',
    ),
  ];

  static Map<String, dynamic> toRuntimePayload(
    List<GameWorldBoardItem> items,
  ) =>
      {
        'mode': 'hybrid',
        'items': items.map((item) => item.toMap()).toList(),
        'leftSide': 'world-exploration',
        'rightSide': 'archive-display',
      };
}

/// Maps the shared Galaxy node hierarchy into a Game World destination without
/// creating a second navigation/data system.
class GameWorldDestination {
  final GalaxyNode worldNode;

  const GameWorldDestination(this.worldNode);

  bool get isWorld => worldNode.nodeType == 'world';
}

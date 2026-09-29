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

enum GameWorldFindAction {
  browse,
  locateInWorld,
}

class GameWorldBoardItem {
  final String key;
  final String title;
  final String subtitle;
  final String? targetNodeKey;
  final GameWorldNavigationMode mode;

  const GameWorldBoardItem({
    required this.key,
    required this.title,
    required this.subtitle,
    this.targetNodeKey,
    this.mode = GameWorldNavigationMode.archiveBoard,
  });

  Map<String, dynamic> toMap() => {
        'key': key,
        'title': title,
        'subtitle': subtitle,
        'mode': mode.name,
        if (targetNodeKey != null) 'targetNodeKey': targetNodeKey,
      };
}

/// A single Quick Find request. Search UI can be added later without changing
/// the world/archive data model.
class GameWorldFindRequest {
  final String query;
  final GameWorldFindAction action;

  const GameWorldFindRequest({
    required this.query,
    this.action = GameWorldFindAction.browse,
  });

  Map<String, dynamic> toMap() => {
        'query': query.trim(),
        'action': action.name,
      };
}

class GameWorldFindResult {
  final GalaxyNode node;
  final String matchType;

  const GameWorldFindResult({
    required this.node,
    required this.matchType,
  });

  Map<String, dynamic> toMap() => {
        'nodeKey': node.nodeKey,
        'title': node.title,
        'nodeType': node.nodeType,
        'matchType': matchType,
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
      mode: GameWorldNavigationMode.quickFind,
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
        'quickFind': {
          'enabled': true,
          'actions': [
            GameWorldFindAction.browse.name,
            GameWorldFindAction.locateInWorld.name,
          ],
        },
      };

  /// Searches the same Galaxy node list used by the spatial world. This is a
  /// foundation-level matcher only; ranking/full-text indexing comes later.
  static List<GameWorldFindResult> find(
    Iterable<GalaxyNode> nodes,
    GameWorldFindRequest request,
  ) {
    final query = request.query.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final results = <GameWorldFindResult>[];
    for (final node in nodes) {
      final title = node.title.toLowerCase();
      final key = node.nodeKey.toLowerCase();

      if (title == query || key == query) {
        results.add(GameWorldFindResult(node: node, matchType: 'exact'));
      } else if (title.contains(query) || key.contains(query)) {
        results.add(GameWorldFindResult(node: node, matchType: 'contains'));
      }
    }
    return results;
  }
}

/// Maps the shared Galaxy node hierarchy into a Game World destination without
/// creating a second navigation/data system.
class GameWorldDestination {
  final GalaxyNode worldNode;

  const GameWorldDestination(this.worldNode);

  bool get isWorld => worldNode.nodeType == 'world';
}

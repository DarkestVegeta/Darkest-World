enum DarkestWorldAccess {
  visitor,
  member,
}

class DarkestWorldAccessPolicy {
  const DarkestWorldAccessPolicy._();

  static const visitorMenu = <String>[
    'Games',
    'Films',
    'Chatbox',
  ];

  // The Galaxy itself is always visible. Login is for access to protected
  // functions/content, not for hiding the DarkestWorld background universe.
  static bool canEnterGalaxy({required bool signedIn}) => true;

  static bool canOpenWorld(String slug, {required bool signedIn}) {
    if (signedIn) return true;
    return slug == 'game-world' ||
        slug == 'cinema-world' ||
        slug == 'chatbox';
  }
}

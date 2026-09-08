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

  static bool canEnterGalaxy({required bool signedIn}) => signedIn;

  static bool canOpenWorld(String slug, {required bool signedIn}) {
    if (signedIn) return true;
    return slug == 'game-world' ||
        slug == 'cinema-world' ||
        slug == 'chatbox';
  }
}

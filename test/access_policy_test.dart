import 'package:darkest_world/core/access_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visitors can see the Galaxy without signing in', () {
    expect(
      DarkestWorldAccessPolicy.canEnterGalaxy(signedIn: false),
      isTrue,
    );
    expect(
      DarkestWorldAccessPolicy.canEnterGalaxy(signedIn: true),
      isTrue,
    );
  });

  test('visitors can open the public worlds', () {
    expect(
      DarkestWorldAccessPolicy.canOpenWorld(
        'game-world',
        signedIn: false,
      ),
      isTrue,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld(
        'cinema-world',
        signedIn: false,
      ),
      isTrue,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld(
        'chatbox',
        signedIn: false,
      ),
      isTrue,
    );
  });

  test('members can open protected worlds', () {
    expect(
      DarkestWorldAccessPolicy.canOpenWorld(
        'darkest-identity',
        signedIn: true,
      ),
      isTrue,
    );
  });

  test('visitors cannot open protected worlds', () {
    expect(
      DarkestWorldAccessPolicy.canOpenWorld(
        'darkest-identity',
        signedIn: false,
      ),
      isFalse,
    );
  });
}

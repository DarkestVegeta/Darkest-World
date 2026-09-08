import 'package:darkest_world/core/access_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('visitor menu exposes exactly Games, Films and Chatbox', () {
    expect(
      DarkestWorldAccessPolicy.visitorMenu,
      ['Games', 'Films', 'Chatbox'],
    );
  });

  test('visitor cannot enter the Galaxy', () {
    expect(
      DarkestWorldAccessPolicy.canEnterGalaxy(signedIn: false),
      isFalse,
    );
    expect(
      DarkestWorldAccessPolicy.canEnterGalaxy(signedIn: true),
      isTrue,
    );
  });

  test('visitor can open only the three public destinations', () {
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('game-world', signedIn: false),
      isTrue,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('cinema-world', signedIn: false),
      isTrue,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('chatbox', signedIn: false),
      isTrue,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('music-world', signedIn: false),
      isFalse,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('events', signedIn: false),
      isFalse,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('create-your-world', signedIn: false),
      isFalse,
    );
  });

  test('members can open all existing world routes', () {
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('music-world', signedIn: true),
      isTrue,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('events', signedIn: true),
      isTrue,
    );
    expect(
      DarkestWorldAccessPolicy.canOpenWorld('create-your-world', signedIn: true),
      isTrue,
    );
  });
}

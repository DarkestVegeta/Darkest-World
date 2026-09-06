import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/world_navigation.dart';

void main() {
  test('maps dedicated worlds to their explicit destinations', () {
    expect(WorldNavigation.destinationForSlug('game-world'), WorldDestination.gameContent);
    expect(WorldNavigation.destinationForSlug('cinema-world'), WorldDestination.movieContent);
    expect(WorldNavigation.destinationForSlug('series-world'), WorldDestination.seriesContent);
    expect(WorldNavigation.destinationForSlug('music-world'), WorldDestination.music);
    expect(WorldNavigation.destinationForSlug('chat'), WorldDestination.chat);
    expect(WorldNavigation.destinationForSlug('events'), WorldDestination.events);
    expect(WorldNavigation.destinationForSlug('marathons'), WorldDestination.marathons);
    expect(WorldNavigation.destinationForSlug('social-media'), WorldDestination.socialMedia);
  });

  test('keeps other current world slugs on the safe foundation page', () {
    const fallbackSlugs = [
      'identity-world',
      'dark-core',
      'chatbox',
      'create-your-world',
    ];

    for (final slug in fallbackSlugs) {
      expect(
        WorldNavigation.destinationForSlug(slug),
        WorldDestination.basic,
        reason: 'Unexpected dedicated routing for $slug',
      );
    }
  });

  test('unknown slugs fail safely to the foundation page', () {
    expect(WorldNavigation.destinationForSlug('future-world'), WorldDestination.basic);
  });
}

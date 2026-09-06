import 'package:flutter_test/flutter_test.dart';
import 'package:darkest_world/core/social_media_world_repository.dart';

void main() {
  test('parses a complete social profile', () {
    final profile = SocialProfile.fromMap({
      'id': 'p1',
      'platform': 'Twitch',
      'profile_name': 'DarkestVegeta',
      'profile_url': 'https://www.twitch.tv/darkestvegeta',
      'category': 'streaming',
      'is_active': true,
      'sort_order': 30,
    });

    expect(profile.platform, 'Twitch');
    expect(profile.profileName, 'DarkestVegeta');
    expect(profile.category, 'streaming');
    expect(profile.isActive, isTrue);
    expect(profile.sortOrder, 30);
  });

  test('uses safe defaults for optional profile values', () {
    final profile = SocialProfile.fromMap({
      'id': 'p1',
      'platform': 'X',
      'profile_name': 'DarkestVegeta',
      'profile_url': 'https://twitter.com/DarkestVegeta',
    });

    expect(profile.category, 'social');
    expect(profile.isActive, isTrue);
    expect(profile.sortOrder, 0);
  });

  test('rejects missing required profile fields', () {
    expect(
      () => SocialProfile.fromMap({
        'id': 'p1',
        'platform': 'X',
        'profile_name': 'DarkestVegeta',
      }),
      throwsFormatException,
    );
  });

  test('parses a social post and optional publication date', () {
    final post = SocialPost.fromMap({
      'id': 'post1',
      'platform': 'YouTube',
      'title': 'New stream',
      'content': 'Live soon.',
      'external_url': 'https://www.youtube.com/@darkestvegeta1',
      'published_at': '2026-09-05T12:00:00Z',
    });

    expect(post.platform, 'YouTube');
    expect(post.title, 'New stream');
    expect(post.publishedAt, isNotNull);
  });

  test('rejects malformed social post publication dates', () {
    expect(
      () => SocialPost.fromMap({
        'id': 'post1',
        'platform': 'YouTube',
        'published_at': 'not-a-date',
      }),
      throwsFormatException,
    );
  });
}

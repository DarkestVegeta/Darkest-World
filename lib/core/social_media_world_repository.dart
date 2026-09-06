import 'package:supabase_flutter/supabase_flutter.dart';

class SocialProfile {
  final String id;
  final String platform;
  final String profileName;
  final String profileUrl;
  final String category;
  final bool isActive;
  final int sortOrder;

  const SocialProfile({
    required this.id,
    required this.platform,
    required this.profileName,
    required this.profileUrl,
    required this.category,
    required this.isActive,
    required this.sortOrder,
  });

  factory SocialProfile.fromMap(Map<String, dynamic> map) {
    final id = _required(map, 'id');
    final platform = _required(map, 'platform');
    final profileName = _required(map, 'profile_name');
    final profileUrl = _required(map, 'profile_url');
    final category = _optionalText(map['category']) ?? 'social';

    return SocialProfile(
      id: id,
      platform: platform,
      profileName: profileName,
      profileUrl: profileUrl,
      category: category,
      isActive: map['is_active'] as bool? ?? true,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class SocialPost {
  final String id;
  final String platform;
  final String? title;
  final String? content;
  final String? externalUrl;
  final DateTime? publishedAt;

  const SocialPost({
    required this.id,
    required this.platform,
    this.title,
    this.content,
    this.externalUrl,
    this.publishedAt,
  });

  factory SocialPost.fromMap(Map<String, dynamic> map) {
    final id = _required(map, 'id');
    final platform = _required(map, 'platform');
    final publishedAt = _optionalDate(map['published_at'], 'published_at');

    return SocialPost(
      id: id,
      platform: platform,
      title: _optionalText(map['title']),
      content: _optionalText(map['content']),
      externalUrl: _optionalText(map['external_url']),
      publishedAt: publishedAt,
    );
  }
}

class SocialMediaWorldData {
  final List<SocialProfile> profiles;
  final List<SocialPost> posts;

  const SocialMediaWorldData({required this.profiles, required this.posts});
}

class SocialMediaWorldRepository {
  final SupabaseClient _client;

  SocialMediaWorldRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<SocialMediaWorldData> load() async {
    final profiles = await _client
        .from('darkestworld_social_profiles')
        .select(
          'id, platform, profile_name, profile_url, category, is_active, sort_order',
        )
        .eq('is_active', true)
        .order('sort_order')
        .order('platform')
        .order('id')
        .then((rows) => rows
            .map((row) => SocialProfile.fromMap(Map<String, dynamic>.from(row)))
            .toList());

    final posts = await _client
        .from('darkestworld_social_posts')
        .select('id, platform, title, content, external_url, published_at')
        .order('published_at', ascending: false, nullsFirst: false)
        .order('id', ascending: false)
        .then((rows) => rows
            .map((row) => SocialPost.fromMap(Map<String, dynamic>.from(row)))
            .toList());

    return SocialMediaWorldData(profiles: profiles, posts: posts);
  }
}

String _required(Map<String, dynamic> map, String key) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing required $key');
  }
  return value.trim();
}

String? _optionalText(dynamic value) {
  if (value == null) return null;
  if (value is! String) {
    throw const FormatException('Expected text value');
  }
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

DateTime? _optionalDate(dynamic value, String key) {
  if (value == null) return null;
  if (value is! String || value.trim().isEmpty) return null;
  final parsed = DateTime.tryParse(value.trim());
  if (parsed == null) throw FormatException('Invalid $key');
  return parsed;
}

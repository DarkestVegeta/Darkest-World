import 'package:flutter/material.dart';

import '../core/social_media_world_repository.dart';

class SocialMediaWorldPage extends StatefulWidget {
  final String title;
  final String? description;

  const SocialMediaWorldPage({
    super.key,
    required this.title,
    this.description,
  });

  @override
  State<SocialMediaWorldPage> createState() => _SocialMediaWorldPageState();
}

class _SocialMediaWorldPageState extends State<SocialMediaWorldPage> {
  final _repository = SocialMediaWorldRepository();
  late Future<SocialMediaWorldData> _data;

  @override
  void initState() {
    super.initState();
    _data = _repository.load();
  }

  void _reload() {
    setState(() => _data = _repository.load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Vernieuwen',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<SocialMediaWorldData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Social Media laden mislukt: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _reload,
                        child: const Text('Opnieuw'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (widget.description?.trim().isNotEmpty ?? false) ...[
                Text(
                  widget.description!.trim(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
              ],
              Text(
                'Platforms',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (data.profiles.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Geen actieve social-profielen beschikbaar.'),
                  ),
                )
              else
                ...data.profiles.map(_profileCard),
              const SizedBox(height: 28),
              Text(
                'Posts',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              if (data.posts.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(18),
                    child: Text('Nog geen social posts gepubliceerd.'),
                  ),
                )
              else
                ...data.posts.map(_postCard),
            ],
          );
        },
      ),
    );
  }

  Widget _profileCard(SocialProfile profile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.public),
        title: Text(profile.platform),
        subtitle: Text('${profile.profileName} · ${profile.category}'),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _openUrl(profile.profileUrl),
      ),
    );
  }

  Widget _postCard(SocialPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.article_outlined),
        title: Text(post.title ?? post.platform),
        subtitle: Text(post.content ?? 'Geen posttekst beschikbaar.'),
        onTap: post.externalUrl == null ? null : () => _openUrl(post.externalUrl!),
      ),
    );
  }

  void _openUrl(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(url)),
    );
  }
}

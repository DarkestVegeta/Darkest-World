import 'package:flutter/material.dart';

import '../core/chat_scope.dart';
import '../core/music_world_repository.dart';
import 'chatbox.dart';

class MusicWorldPage extends StatefulWidget {
  final String title;
  final String description;

  const MusicWorldPage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  State<MusicWorldPage> createState() => _MusicWorldPageState();
}

class _MusicWorldPageState extends State<MusicWorldPage> {
  final _repository = MusicWorldRepository();
  late Future<List<MusicWorldCategory>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _repository.loadCategories();
  }

  void _reload() {
    setState(() => _categories = _repository.loadCategories());
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
      body: FutureBuilder<List<MusicWorldCategory>>(
        future: _categories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Music World laden mislukt: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _reload,
                    child: const Text('Opnieuw'),
                  ),
                ],
              ),
            );
          }

          final categories = snapshot.data ?? const <MusicWorldCategory>[];
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(widget.description),
              const SizedBox(height: 24),
              const Text(
                'Music categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (categories.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Nog geen muziekcategorieën beschikbaar.'),
                  ),
                )
              else
                for (final category in categories)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.music_note),
                      title: Text(category.name),
                      subtitle: category.description.isEmpty
                          ? null
                          : Text(category.description),
                    ),
                  ),
            ],
          );
        },
      ),
      floatingActionButton: const Chatbox(
        contextData: ChatContext(scope: ChatScope.music),
      ),
    );
  }
}

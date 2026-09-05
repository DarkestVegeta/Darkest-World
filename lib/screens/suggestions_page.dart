import 'package:flutter/material.dart';

import '../core/suggestion_repository.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final _repository = SuggestionRepository();
  late Future<List<WorldSuggestion>> _suggestions;

  @override
  void initState() {
    super.initState();
    _suggestions = _repository.getMySuggestions();
  }

  void _reload() {
    setState(() => _suggestions = _repository.getMySuggestions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggesties'),
        actions: [
          IconButton(
            tooltip: 'Vernieuwen',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<WorldSuggestion>>(
        future: _suggestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Suggesties laden mislukt: ${snapshot.error}'));
          }

          final suggestions = snapshot.data ?? const <WorldSuggestion>[];
          if (suggestions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nog geen suggesties.\n\nIGDB en TMDB blijven de externe zoeklaag; Darkest-World bewaart alleen de minimale suggestiegegevens.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: suggestion.imageUrl == null
                      ? const SizedBox(width: 56, child: Icon(Icons.image_outlined))
                      : Image.network(
                          suggestion.imageUrl!,
                          width: 56,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            width: 56,
                            child: Icon(Icons.broken_image_outlined),
                          ),
                        ),
                  title: Text(suggestion.title),
                  subtitle: Text(
                    '${suggestion.contentType} • ${suggestion.source.toUpperCase()} • ${suggestion.soulPoints} Zielen • ${suggestion.status}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

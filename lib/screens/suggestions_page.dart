import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/suggestion_repository.dart';
import '../core/supabase_client.dart';

class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  final _repository = SuggestionRepository();
  late Future<List<WorldSuggestion>> _suggestions;
  StreamSubscription<AuthState>? _authSubscription;
  bool _signedIn = false;

  @override
  void initState() {
    super.initState();
    _signedIn = supabase.auth.currentUser != null;
    _suggestions = _repository.getMySuggestions();
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      setState(() {
        _signedIn = data.session != null;
        _suggestions = _repository.getMySuggestions();
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _reload() {
    setState(() => _suggestions = _repository.getMySuggestions());
  }

  Future<void> _openSubmitForm() async {
    if (!_signedIn) return;
    final submitted = await showDialog<bool>(
      context: context,
      builder: (_) => const _SubmitSuggestionDialog(),
    );
    if (submitted == true && mounted) _reload();
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Suggesties laden mislukt: ${snapshot.error}'),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _reload, child: const Text('Opnieuw')),
                ],
              ),
            );
          }

          final suggestions = snapshot.data ?? const <WorldSuggestion>[];
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Suggestie naar Darkest-World',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _signedIn
                    ? 'Zoek games, films of series via IGDB/TMDB en stuur alleen een suggestie. Een suggestie wordt nooit automatisch aan Darkest-World toegevoegd.'
                    : 'Log in om een suggestie te sturen. Een suggestie wordt nooit automatisch aan Darkest-World toegevoegd.',
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _signedIn ? _openSubmitForm : null,
                icon: const Icon(Icons.add),
                label: const Text('Suggestie indienen'),
              ),
              const SizedBox(height: 28),
              const Text(
                'Mijn suggesties',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (suggestions.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Nog geen suggesties ingediend.'),
                  ),
                )
              else
                for (final suggestion in suggestions)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: suggestion.imageUrl == null
                          ? const SizedBox(
                              width: 56,
                              child: Icon(Icons.image_outlined),
                            )
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
                        '${suggestion.contentType} • ${suggestion.source.toUpperCase()} • ${suggestion.status}',
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _SubmitSuggestionDialog extends StatefulWidget {
  const _SubmitSuggestionDialog();

  @override
  State<_SubmitSuggestionDialog> createState() => _SubmitSuggestionDialogState();
}

class _SubmitSuggestionDialogState extends State<_SubmitSuggestionDialog> {
  final _repository = SuggestionRepository();
  final _queryController = TextEditingController();
  List<ViewerContentResult> _results = const [];
  ViewerContentResult? _selected;
  String _source = 'igdb';
  String _contentType = 'game';
  bool _searching = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_searching || _saving) return;
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Vul eerst een titel in om te zoeken.');
      return;
    }

    setState(() {
      _searching = true;
      _error = null;
      _selected = null;
      _results = const [];
    });

    try {
      final results = await _repository.searchViewerContent(
        source: _source,
        contentType: _contentType,
        query: query,
      );
      if (!mounted) return;
      setState(() => _results = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Zoeken mislukt: $e');
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _submit() async {
    final selected = _selected;
    if (_saving || selected == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _repository.submit(
        source: selected.source,
        contentType: selected.contentType,
        externalId: selected.externalId,
        title: selected.title,
        imageUrl: selected.imageUrl,
        soulPoints: 0,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Suggestie indienen mislukt: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _changeSource(String value) {
    final contentType = value == 'igdb' ? 'game' : 'movie';
    setState(() {
      _source = value;
      _contentType = contentType;
      _results = const [];
      _selected = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nieuwe suggestie'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Zoek eerst de officiële titel. Alleen het door jou gekozen resultaat wordt als suggestie verstuurd.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _source,
                      decoration: const InputDecoration(labelText: 'Bron'),
                      items: const [
                        DropdownMenuItem(value: 'igdb', child: Text('IGDB — Games')),
                        DropdownMenuItem(value: 'tmdb', child: Text('TMDB — Films/Series')),
                      ],
                      onChanged: _searching || _saving
                          ? null
                          : (value) => _changeSource(value!),
                    ),
                  ),
                  if (_source == 'tmdb') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _contentType,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(value: 'movie', child: Text('Film')),
                          DropdownMenuItem(value: 'series', child: Text('Serie')),
                        ],
                        onChanged: _searching || _saving
                            ? null
                            : (value) => setState(() {
                                  _contentType = value!;
                                  _results = const [];
                                  _selected = null;
                                }),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _queryController,
                enabled: !_searching && !_saving,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  labelText: 'Zoek op titel',
                  hintText: _contentType == 'game' ? 'Bijv. Halo' : 'Bijv. Alien',
                  suffixIcon: IconButton(
                    tooltip: 'Zoeken',
                    onPressed: _searching || _saving ? null : _search,
                    icon: _searching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.search),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
              if (!_searching && _results.isEmpty && _queryController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Geen resultaten gevonden.'),
              ],
              if (_results.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Kies een resultaat',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                for (final result in _results)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      selected: identical(_selected, result),
                      leading: result.imageUrl == null
                          ? const Icon(Icons.movie_outlined)
                          : Image.network(
                              result.imageUrl!,
                              width: 48,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined),
                            ),
                      title: Text(result.title),
                      subtitle: Text(
                        [
                          result.releaseDate,
                          result.description,
                        ].whereType<String>().where((value) => value.isNotEmpty).join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: identical(_selected, result)
                          ? const Icon(Icons.check_circle)
                          : null,
                      onTap: _saving ? null : () => setState(() => _selected = result),
                    ),
                  ),
              ],
              if (_selected != null) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text('Gekozen: ${_selected!.title}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton.icon(
          onPressed: _saving || _selected == null ? null : _submit,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: const Text('Suggestie sturen'),
        ),
      ],
    );
  }
}

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
                    ? 'Zoek games, films of series op IGDB/TMDB. Darkest-World bewaart alleen de minimale gegevens van wat je wilt voorstellen.'
                    : 'Log in om suggesties te bekijken en in te dienen. Darkest-World bewaart alleen de minimale gegevens van wat je wilt voorstellen.',
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
                        '${suggestion.contentType} • ${suggestion.source.toUpperCase()} • ${suggestion.soulPoints} Zielen • ${suggestion.status}',
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
  final _formKey = GlobalKey<FormState>();
  final _externalId = TextEditingController();
  final _title = TextEditingController();
  final _imageUrl = TextEditingController();
  final _soulPoints = TextEditingController(text: '0');
  String _source = 'igdb';
  String _contentType = 'game';
  bool _saving = false;

  @override
  void dispose() {
    _externalId.dispose();
    _title.dispose();
    _imageUrl.dispose();
    _soulPoints.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await _repository.submit(
        source: _source,
        contentType: _contentType,
        externalId: _externalId.text,
        title: _title.text,
        imageUrl: _imageUrl.text,
        soulPoints: int.parse(_soulPoints.text.trim()),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suggestie indienen mislukt: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nieuwe suggestie'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _source,
                  decoration: const InputDecoration(labelText: 'Bron'),
                  items: const [
                    DropdownMenuItem(value: 'igdb', child: Text('IGDB')),
                    DropdownMenuItem(value: 'tmdb', child: Text('TMDB')),
                  ],
                  onChanged: _saving ? null : (value) => setState(() => _source = value!),
                ),
                DropdownButtonFormField<String>(
                  initialValue: _contentType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: 'game', child: Text('Game')),
                    DropdownMenuItem(value: 'movie', child: Text('Movie')),
                    DropdownMenuItem(value: 'series', child: Text('Series')),
                  ],
                  onChanged: _saving ? null : (value) => setState(() => _contentType = value!),
                ),
                TextFormField(
                  controller: _externalId,
                  decoration: const InputDecoration(labelText: 'IGDB/TMDB ID'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Externe ID is verplicht.'
                      : null,
                ),
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Titel'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Titel is verplicht.'
                      : null,
                ),
                TextFormField(
                  controller: _imageUrl,
                  decoration: const InputDecoration(labelText: 'Afbeelding URL (optioneel)'),
                ),
                TextFormField(
                  controller: _soulPoints,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Zielenpunten'),
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed < 0) return 'Gebruik 0 of een positief getal.';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Indienen'),
        ),
      ],
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/chat_repository.dart';
import '../core/chat_scope.dart';
import '../core/chat_search_repository.dart';
import '../core/supabase_client.dart';

class ChatWorldPage extends StatefulWidget {
  final ChatContext? context;
  final bool marathonChatActive;

  const ChatWorldPage({
    super.key,
    this.context,
    this.marathonChatActive = false,
  });

  @override
  State<ChatWorldPage> createState() => _ChatWorldPageState();
}

class _ChatWorldPageState extends State<ChatWorldPage> {
  final _repository = ChatRepository();
  final _searchRepository = ChatSearchRepository();
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();
  late ChatScope _scope;
  StreamSubscription<AuthState>? _authSubscription;
  Stream<List<ChatMessage>>? _messageStream;
  List<ChatSearchResult> _searchResults = [];
  bool _signedIn = false;
  bool _sending = false;
  bool _searching = false;
  String? _searchError;
  String? _selectedContentId;
  String? _selectedContentTitle;

  @override
  void initState() {
    super.initState();
    _scope = widget.context?.scope ?? ChatScope.games;
    if (_scope == ChatScope.marathon && !widget.marathonChatActive) {
      _scope = ChatScope.games;
    }
    _selectedContentId = widget.context?.contentId;
    _selectedContentTitle = widget.context?.contentTitle;
    _signedIn = supabase.auth.currentUser != null;
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (!mounted) return;
      setState(() {
        _signedIn = data.session != null;
      });
    });
    _resetStream();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  ChatContext get _activeContext {
    return ChatContext(
      scope: _scope,
      contentId: _selectedContentId,
      contentTitle: _selectedContentTitle,
      marathonChatActive: widget.marathonChatActive,
    );
  }

  void _resetStream() {
    final active = _activeContext;
    if (!active.isAvailable) {
      _messageStream = null;
      return;
    }

    _messageStream = _repository.streamMessages(
      scope: active.scope,
      contentId: active.scope == ChatScope.marathon ? null : active.contentId,
      marathonId: active.scope == ChatScope.marathon ? active.contentId : null,
    );
  }

  void _selectScope(ChatScope scope) {
    if (_scope == scope) return;
    setState(() {
      _scope = scope;
      _selectedContentId = null;
      _selectedContentTitle = null;
      _searchResults = [];
      _searchError = null;
      _resetStream();
    });
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _searchError = null;
      });
      return;
    }

    setState(() {
      _searching = true;
      _searchError = null;
    });

    try {
      final results = await _searchRepository.search(
        scope: _scope,
        query: query,
        contentId: _scope == ChatScope.marathon ? _selectedContentId : null,
      );
      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searchResults = [];
        _searchError = e.toString();
      });
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _useSearchResult(ChatSearchResult result) {
    if (result.contentId == null ||
        (_scope != ChatScope.games &&
            _scope != ChatScope.movies &&
            _scope != ChatScope.series)) {
      return;
    }

    setState(() {
      _selectedContentId = result.contentId;
      _selectedContentTitle = result.title;
      _searchResults = [];
      _searchController.clear();
      _resetStream();
    });
  }

  Future<void> _sendMessage() async {
    if (_sending || !_signedIn) return;
    final active = _activeContext;
    if (!active.isAvailable) return;

    setState(() => _sending = true);
    try {
      await _repository.sendMessage(
        context: active,
        message: _messageController.text,
      );
      _messageController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bericht versturen mislukt: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scopes = ChatAccessPolicy.allowedScopesForFullscreen(
      marathonChatActive: widget.marathonChatActive,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          PopupMenuButton<ChatScope>(
            tooltip: 'Chat kiezen',
            onSelected: _selectScope,
            itemBuilder: (_) => [
              for (final scope in scopes)
                PopupMenuItem(value: scope, child: Text(_scopeLabel(scope))),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(flex: 5, child: _browsePanel(scopes)),
          const VerticalDivider(width: 1),
          Expanded(flex: 5, child: _chatPanel()),
        ],
      ),
    );
  }

  String get _title {
    final contentTitle = _activeContext.contentTitle;
    if (contentTitle != null && contentTitle.trim().isNotEmpty) {
      return '${_scopeLabel(_scope)} · $contentTitle';
    }
    return _scopeLabel(_scope);
  }

  Widget _browsePanel(List<ChatScope> scopes) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Live World',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hier kies je binnen de chatwereld waar je over wilt praten.',
        ),
        const SizedBox(height: 24),
        for (final scope in scopes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              onPressed: () => _selectScope(scope),
              icon: Icon(_scopeIcon(scope)),
              label: Text(_scopeLabel(scope)),
            ),
          ),
        if (!widget.marathonChatActive) ...[
          const SizedBox(height: 12),
          const Text(
            'Marathon Chat is momenteel niet actief. Dit staat los van Twitch of streaming en wordt actief wanneer de Marathon-chatcontext wordt geopend.',
          ),
        ],
        const SizedBox(height: 24),
        Text(
          'Zoeken binnen ${_scopeLabel(_scope)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _search(),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Zoek content of onderwerp...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Zoeken',
              onPressed: _searching ? null : _search,
              icon: _searching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
            ),
          ],
        ),
        if (_searchError != null) ...[
          const SizedBox(height: 12),
          Text(
            'Zoeken mislukt: $_searchError',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (_searchController.text.trim().isNotEmpty &&
            !_searching &&
            _searchError == null &&
            _searchResults.isEmpty) ...[
          const SizedBox(height: 12),
          const Text('Geen resultaten gevonden.'),
        ],
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final result in _searchResults)
            Card(
              child: ListTile(
                leading: const Icon(Icons.search),
                title: Text(result.title),
                subtitle: result.subtitle.isEmpty
                    ? null
                    : Text(result.subtitle),
                trailing: result.contentId != null &&
                        _scope != ChatScope.music &&
                        _scope != ChatScope.marathon
                    ? const Icon(Icons.arrow_forward)
                    : null,
                onTap: result.contentId == null
                    ? null
                    : () => _useSearchResult(result),
              ),
            ),
        ],
      ],
    );
  }

  Widget _chatPanel() {
    final active = _activeContext;
    if (!active.isAvailable) {
      return const Center(child: Text('Marathon Chat is momenteel niet actief.'));
    }

    final stream = _messageStream;
    if (stream == null) {
      return const Center(child: Text('Chatverbinding niet beschikbaar.'));
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(_signedIn ? 'Ingelogd · chatten beschikbaar' : 'Niet ingelogd · lezen is beschikbaar'),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Chat laden mislukt: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final messages = snapshot.data ?? const <ChatMessage>[];
              if (messages.isEmpty) {
                return const Center(child: Text('Nog geen berichten in deze chatcontext.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (_, index) {
                  final message = messages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.authorId ?? 'Onbekend',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(message.message),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: _signedIn && !_sending,
                  maxLines: 3,
                  minLines: 1,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: _signedIn
                        ? 'Typ een bericht...'
                        : 'Log in om een bericht te plaatsen...',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _signedIn && !_sending ? _sendMessage : null,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _scopeLabel(ChatScope scope) {
    switch (scope) {
      case ChatScope.games:
        return 'Games';
      case ChatScope.movies:
        return 'Movies';
      case ChatScope.series:
        return 'Series';
      case ChatScope.music:
        return 'Music';
      case ChatScope.marathon:
        return 'Marathon';
    }
  }

  IconData _scopeIcon(ChatScope scope) {
    switch (scope) {
      case ChatScope.games:
        return Icons.sports_esports;
      case ChatScope.movies:
        return Icons.movie;
      case ChatScope.series:
        return Icons.tv;
      case ChatScope.music:
        return Icons.music_note;
      case ChatScope.marathon:
        return Icons.directions_run;
    }
  }
}

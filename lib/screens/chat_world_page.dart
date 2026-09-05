import 'package:flutter/material.dart';
import '../core/chat_repository.dart';
import '../core/chat_scope.dart';

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
  final _messageController = TextEditingController();
  late ChatScope _scope;
  List<ChatMessage> _messages = const [];
  bool _loadingMessages = false;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scope = widget.context?.scope ?? ChatScope.games;
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  ChatContext get _activeContext {
    final original = widget.context;
    final sameContext = original != null && original.scope == _scope;
    return ChatContext(
      scope: _scope,
      contentId: sameContext ? original.contentId : null,
      contentTitle: sameContext ? original.contentTitle : null,
      marathonChatActive: widget.marathonChatActive,
    );
  }

  Future<void> _selectScope(ChatScope scope) async {
    if (_scope == scope) return;
    setState(() => _scope = scope);
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    final active = _activeContext;
    if (!active.isAvailable) {
      if (!mounted) return;
      setState(() {
        _messages = const [];
        _loadingMessages = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _loadingMessages = true;
      _error = null;
    });

    try {
      final messages = await _repository.getMessages(
        scope: active.scope,
        contentId: active.scope == ChatScope.marathon ? null : active.contentId,
        marathonId: null,
      );
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loadingMessages = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMessages = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_sending) return;
    final active = _activeContext;
    if (!active.isAvailable) return;

    setState(() => _sending = true);
    try {
      await _repository.sendMessage(
        context: active,
        message: _messageController.text,
      );
      _messageController.clear();
      await _loadMessages();
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
          IconButton(
            tooltip: 'Berichten vernieuwen',
            onPressed: _loadingMessages ? null : _loadMessages,
            icon: const Icon(Icons.refresh),
          ),
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
        const TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Zoek content of onderwerp...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _chatPanel() {
    final active = _activeContext;
    if (!active.isAvailable) {
      return const Center(child: Text('Marathon Chat is momenteel niet actief.'));
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            _title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _messagesView()),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  maxLines: 3,
                  minLines: 1,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Typ een bericht...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _sending ? null : _sendMessage,
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

  Widget _messagesView() {
    if (_loadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Chat laden mislukt: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadMessages, child: const Text('Opnieuw')),
          ],
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Text('Nog geen berichten in deze chatcontext.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (_, index) {
        final message = _messages[index];
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

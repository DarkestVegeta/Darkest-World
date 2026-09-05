import 'package:flutter/material.dart';
import '../core/chat_scope.dart';

class ChatWorldPage extends StatefulWidget {
  final ChatContext? context;
  final bool marathonLive;

  const ChatWorldPage({super.key, this.context, this.marathonLive = false});

  @override
  State<ChatWorldPage> createState() => _ChatWorldPageState();
}

class _ChatWorldPageState extends State<ChatWorldPage> {
  late ChatScope _scope;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scope = widget.context?.scope ?? ChatScope.games;
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scopes = ChatAccessPolicy.allowedScopesForFullscreen(
      marathonLive: widget.marathonLive,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          PopupMenuButton<ChatScope>(
            tooltip: 'Chat kiezen',
            onSelected: (scope) => setState(() => _scope = scope),
            itemBuilder: (_) => [
              for (final scope in scopes)
                PopupMenuItem(value: scope, child: Text(_scopeLabel(scope))),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 5,
            child: _browsePanel(scopes),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 5,
            child: _chatPanel(),
          ),
        ],
      ),
    );
  }

  String get _title {
    final contentTitle = widget.context?.contentTitle;
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
          'Tijdens het chatten kun je hier binnen de beschikbare chatwerelden zoeken.',
        ),
        const SizedBox(height: 24),
        for (final scope in scopes)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _scope = scope),
              icon: Icon(_scopeIcon(scope)),
              label: Text(_scopeLabel(scope)),
            ),
          ),
        if (!widget.marathonLive) ...[
          const SizedBox(height: 12),
          const Text(
            'Marathon Chat is momenteel niet actief. Deze verschijnt alleen tijdens een live marathon.',
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
        const Expanded(
          child: Center(
            child: Text(
              'Chatberichten worden hier geladen.\nDe huidige basis koppelt de chat aan de actieve wereld/context.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Typ een bericht...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {},
                child: const Icon(Icons.send),
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

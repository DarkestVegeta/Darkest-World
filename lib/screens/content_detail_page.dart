import 'package:flutter/material.dart';

import '../core/chat_scope.dart';
import '../core/content_repository.dart';
import 'chatbox.dart';

class ContentDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ContentDetailPage({super.key, required this.item});

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  final _repository = ContentRepository();
  List<Map<String, dynamic>> _related = const [];
  FranchiseNavigation? _navigation;
  bool _loading = true;
  String? _error;

  String get _title => '${widget.item['title'] ?? 'Untitled'}';
  String get _type => '${widget.item['content_type'] ?? ''}';
  String get _franchise => '${widget.item['franchise'] ?? ''}';
  String get _description => '${widget.item['description'] ?? ''}';

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final id = widget.item['id'];
    try {
      final results = await Future.wait([
        id == null ? Future.value(<Map<String, dynamic>>[]) : _repository.getRelatedContent('$id'),
        _repository.getFranchiseNavigation(widget.item),
      ]);
      if (!mounted) return;
      setState(() {
        _related = results[0] as List<Map<String, dynamic>>;
        _navigation = results[1] as FranchiseNavigation?;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  ChatContext? get _chatContext {
    ChatScope? scope;
    switch (_type) {
      case 'game':
        scope = ChatScope.games;
        break;
      case 'movie':
        scope = ChatScope.movies;
        break;
      case 'series':
        scope = ChatScope.series;
        break;
      default:
        return null;
    }
    return ChatContext(
      scope: scope,
      contentId: widget.item['id']?.toString(),
      contentTitle: _title,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(36, 32, 36, 48),
        children: [
          Text(
            _title,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              if (_type.isNotEmpty) Chip(label: Text(_type.toUpperCase())),
              if (_franchise.isNotEmpty) Chip(label: Text(_franchise)),
            ],
          ),
          if (_description.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(_description, style: Theme.of(context).textTheme.bodyLarge),
          ],
          const SizedBox(height: 36),
          const Text(
            'Previous | CURRENT | Next',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const SizedBox(height: 110, child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Text('Franchise-navigatie laden mislukt: $_error')
          else if (_navigation == null)
            const Text('Geen franchisevolgorde beschikbaar voor dit item.')
          else
            _navigationRow(context),
          const SizedBox(height: 36),
          const Text(
            'Related',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            )
          else if (_error != null)
            Text('Related laden mislukt: $_error')
          else if (_related.isEmpty)
            const Text('Nog geen gekoppelde Related-content.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in _related)
                  SizedBox(
                    width: 220,
                    child: Card(
                      child: ListTile(
                        title: Text('${item['title'] ?? 'Untitled'}'),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContentDetailPage(item: item),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
      floatingActionButton: _chatContext == null
          ? null
          : Chatbox(contextData: _chatContext!),
    );
  }

  Widget _navigationRow(BuildContext context) {
    final navigation = _navigation!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _navigationCard(context, navigation.previous, 'Previous', false)),
        const SizedBox(width: 18),
        Expanded(flex: 2, child: _navigationCard(context, navigation.current, 'CURRENT', true)),
        const SizedBox(width: 18),
        Expanded(child: _navigationCard(context, navigation.next, 'Next', false)),
      ],
    );
  }

  Widget _navigationCard(
    BuildContext context,
    Map<String, dynamic>? item,
    String label,
    bool current,
  ) {
    final enabled = item != null;
    return Card(
      elevation: current ? 8 : 2,
      child: InkWell(
        onTap: !enabled || current
            ? null
            : () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContentDetailPage(item: item),
                  ),
                ),
        child: Padding(
          padding: EdgeInsets.all(current ? 24 : 16),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(
                enabled ? '${item!['title'] ?? 'Untitled'}' : '—',
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: current ? 22 : 16,
                  fontWeight: current ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

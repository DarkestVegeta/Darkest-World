import 'package:flutter/material.dart';

import '../core/chat_scope.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import 'chatbox.dart';

class ContentDetailPage extends StatefulWidget {
  final ContentItem item;

  const ContentDetailPage({super.key, required this.item});

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  final _repository = ContentRepository();
  List<ContentItem> _related = const [];
  TypedFranchiseNavigation? _navigation;
  bool _relatedLoading = true;
  bool _navigationLoading = true;
  String? _relatedError;
  String? _navigationError;

  String get _title => widget.item.title;
  String get _type => widget.item.type.name;
  String get _franchise => widget.item.franchise ?? '';
  String get _description => widget.item.description ?? '';

  @override
  void initState() {
    super.initState();
    _loadRelated();
    _loadNavigation();
  }

  Future<void> _loadRelated() async {
    try {
      final related = await _repository.getRelatedContentItems(widget.item.id);
      if (!mounted) return;
      setState(() {
        _related = related;
        _relatedLoading = false;
        _relatedError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _relatedLoading = false;
        _relatedError = e.toString();
      });
    }
  }

  Future<void> _loadNavigation() async {
    try {
      final navigation = await _repository.getTypedFranchiseNavigation(widget.item);
      if (!mounted) return;
      setState(() {
        _navigation = navigation;
        _navigationLoading = false;
        _navigationError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _navigationLoading = false;
        _navigationError = e.toString();
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
      contentId: widget.item.id,
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
              if (_type != 'unknown') Chip(label: Text(_type.toUpperCase())),
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
          if (_navigationLoading)
            const SizedBox(
              height: 110,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_navigationError != null)
            Text('Franchise-navigatie laden mislukt: $_navigationError')
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
          if (_relatedLoading)
            const Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            )
          else if (_relatedError != null)
            Text('Related laden mislukt: $_relatedError')
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
                        title: Text(item.title),
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
        Expanded(
          child: _navigationCard(
            context,
            navigation.previous,
            'Previous',
            false,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 2,
          child: _navigationCard(
            context,
            navigation.current,
            'CURRENT',
            true,
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child: _navigationCard(
            context,
            navigation.next,
            'Next',
            false,
          ),
        ),
      ],
    );
  }

  Widget _navigationCard(
    BuildContext context,
    ContentItem? item,
    String label,
    bool current,
  ) {
    final title = item == null ? '—' : item.title;
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
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(
                title,
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

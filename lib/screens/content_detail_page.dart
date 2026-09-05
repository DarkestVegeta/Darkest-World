import 'package:flutter/material.dart';
import '../core/content_repository.dart';

class ContentDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ContentDetailPage({super.key, required this.item});

  @override
  State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> {
  final _repository = ContentRepository();
  List<Map<String, dynamic>> _related = const [];
  bool _loadingRelated = true;
  String? _error;

  String get _title => '${widget.item['title'] ?? 'Untitled'}';
  String get _type => '${widget.item['content_type'] ?? ''}';
  String get _franchise => '${widget.item['franchise'] ?? ''}';
  String get _description => '${widget.item['description'] ?? ''}';

  @override
  void initState() {
    super.initState();
    _loadRelated();
  }

  Future<void> _loadRelated() async {
    final id = widget.item['id'];
    if (id == null) {
      setState(() => _loadingRelated = false);
      return;
    }

    try {
      final related = await _repository.getRelatedContent('$id');
      if (!mounted) return;
      setState(() {
        _related = related;
        _loadingRelated = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loadingRelated = false;
      });
    }
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
            Text(
              _description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 36),
          const Text(
            'Previous | CURRENT | Next',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const Text(
            'Franchise navigation is ready for timeline data. The current item remains the central detail page.',
          ),
          const SizedBox(height: 36),
          const Text(
            'Related',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (_loadingRelated)
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
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('${item['title'] ?? 'Untitled'}'),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

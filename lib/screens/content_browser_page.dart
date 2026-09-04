import 'package:flutter/material.dart';
import '../core/content_repository.dart';

class ContentBrowserPage extends StatefulWidget {
  final String? contentType;
  final String title;

  const ContentBrowserPage({
    super.key,
    required this.title,
    this.contentType,
  });

  @override
  State<ContentBrowserPage> createState() => _ContentBrowserPageState();
}

class _ContentBrowserPageState extends State<ContentBrowserPage> {
  final _repository = ContentRepository();
  final _scrollController = ScrollController();
  final _items = <Map<String, dynamic>>[];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await _repository.getContentPage(
        type: widget.contentType,
        page: _page,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _page++;
        _hasMore = page.length == ContentRepository.pageSize;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _items.clear();
            _page = 0;
            _hasMore = true;
          });
          await _loadNextPage();
        },
        child: _error != null && _items.isEmpty
            ? ListView(children: [
                SizedBox(height: 240),
                Center(child: Text('Laden mislukt: $_error')),
              ])
            : ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _items.length + (_loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = _items[index];
                  return ListTile(
                    title: Text('${item['title'] ?? 'Untitled'}'),
                    subtitle: Text(
                      '${item['content_type'] ?? ''}',
                    ),
                  );
                },
              ),
      ),
    );
  }
}

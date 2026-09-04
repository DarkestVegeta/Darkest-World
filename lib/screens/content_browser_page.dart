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
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 700) {
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

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _error = null;
    });
    await _loadNextPage();
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
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null && _items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 220),
          Center(child: Text('Laden mislukt: $_error')),
          const SizedBox(height: 16),
          Center(child: OutlinedButton(onPressed: _loadNextPage, child: const Text('Opnieuw'))),
        ],
      );
    }

    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 220),
          Center(child: Text('Geen content gevonden.')),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final sidePadding = width >= 1500 ? 56.0 : 36.0;
        final gap = width >= 1500 ? 18.0 : 14.0;
        final available = width - (sidePadding * 2) - (gap * 4);
        final cardWidth = available / 5;
        final cardHeight = cardWidth * 1.42;

        return ListView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(sidePadding, 28, sidePadding, 48),
          children: [
            SizedBox(
              height: cardHeight + 76,
              child: _FocusRow(
                items: _items.take(5).toList(),
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                gap: gap,
              ),
            ),
            const SizedBox(height: 36),
            if (_items.length > 5)
              Wrap(
                spacing: gap,
                runSpacing: gap,
                children: _items.skip(5).map((item) {
                  return _ContentCard(
                    item: item,
                    width: cardWidth,
                    height: cardHeight,
                  );
                }).toList(),
              ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_hasMore && !_loading)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: Text('Einde van de collectie')),
              ),
          ],
        );
      },
    );
  }
}

class _FocusRow extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double cardWidth;
  final double cardHeight;
  final double gap;

  const _FocusRow({
    required this.items,
    required this.cardWidth,
    required this.cardHeight,
    required this.gap,
  });

  @override
  State<_FocusRow> createState() => _FocusRowState();
}

class _FocusRowState extends State<_FocusRow> {
  int _focused = 2;

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(items.length, (index) {
        final isMain = index == _focused;
        final scale = isMain ? 1.10 : 1.0;
        final width = widget.cardWidth * scale;
        final height = widget.cardHeight * scale;

        return Padding(
          padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : widget.gap),
          child: SizedBox(
            width: width,
            height: height,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => setState(() => _focused = index),
              child: _ContentCard(
                item: items[index],
                width: width,
                height: height,
                highlighted: isMain,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final double width;
  final double height;
  final bool highlighted;

  const _ContentCard({
    required this.item,
    required this.width,
    required this.height,
    this.highlighted = false,
  });

  String get _title => '${item['title'] ?? 'Untitled'}';

  @override
  Widget build(BuildContext context) {
    final metadata = item['metadata'] is Map
        ? Map<String, dynamic>.from(item['metadata'] as Map)
        : <String, dynamic>{};
    final imageUrl = '${item['public_url'] ?? metadata['public_url'] ?? metadata['image_url'] ?? ''}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: highlighted ? 2 : 1,
          color: highlighted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: highlighted
            ? [const BoxShadow(blurRadius: 18, spreadRadius: 1)]
            : const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _Placeholder(title: _title))
                : _Placeholder(title: _title),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            child: Text(
              _title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(title, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

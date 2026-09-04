import 'dart:math' as math;
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
  double _focusedIndex = 2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    const cardWidth = 220.0;
    const gap = 18.0;
    final step = cardWidth + gap;
    final center = _scrollController.offset / step + 2;
    if ((_focusedIndex - center).abs() > 0.05) {
      setState(() => _focusedIndex = center);
    }

    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <
        step * 5) {
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
      _focusedIndex = 2;
    });
    _scrollController.jumpTo(0);
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
        final sidePadding = constraints.maxWidth >= 1500 ? 56.0 : 36.0;
        final gap = constraints.maxWidth >= 1500 ? 18.0 : 14.0;
        final available = constraints.maxWidth - sidePadding * 2 - gap * 4;
        final baseWidth = math.max(150.0, available / 5);
        final baseHeight = baseWidth * 1.42;
        final step = baseWidth + gap;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 28),
            SizedBox(
              height: baseHeight + 72,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: sidePadding),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final distance = (index - _focusedIndex).abs();
                  final isMain = distance < 0.5;
                  final scale = isMain ? 1.10 : 1.0;
                  final width = baseWidth * scale;
                  final height = baseHeight * scale;

                  return SizedBox(
                    width: width,
                    height: height,
                    child: Padding(
                      padding: EdgeInsets.only(right: gap),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => _focusItem(index, step),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOut,
                          alignment: Alignment.center,
                          child: _ContentCard(
                            item: _items[index],
                            width: width,
                            height: height,
                            highlighted: isMain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!_hasMore && !_loading)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: Text('Einde van de collectie')),
              ),
          ],
        );
      },
    );
  }

  void _focusItem(int index, double step) {
    final target = math.max(0.0, (index - 2) * step);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
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

  @override
  Widget build(BuildContext context) {
    final title = '${item['title'] ?? 'Untitled'}';
    final metadata = item['metadata'] is Map
        ? Map<String, dynamic>.from(item['metadata'] as Map)
        : <String, dynamic>{};
    final imageUrl = '${item['public_url'] ?? metadata['public_url'] ?? metadata['image_url'] ?? ''}';

    return Container(
      width: width,
      height: height,
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
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _Placeholder(title: title),
                  )
                : _Placeholder(title: title),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500),
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
        child: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/content_browser_layout.dart';
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
  bool _initialCenterApplied = false;
  int _page = 0;
  double _focusedIndex = 2;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final width = _scrollController.position.viewportDimension;
    final step = _cardWidth(width) + _gap(width);
    if (step > 0) {
      final nextFocus = ContentBrowserLayout.focusedIndex(
        offset: _scrollController.offset,
        step: step,
        itemCount: _items.length,
      ).toDouble();
      if (nextFocus != _focusedIndex && mounted) {
        setState(() => _focusedIndex = nextFocus);
      }
    }

    if (_scrollController.position.maxScrollExtent -
            _scrollController.position.pixels <
        1200) {
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
      _centerInitialMainIfReady();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _centerInitialMainIfReady() {
    if (_initialCenterApplied || _items.length < 5 || !_scrollController.hasClients) {
      return;
    }
    _initialCenterApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final width = _scrollController.position.viewportDimension;
      final step = _cardWidth(width) + _gap(width);
      _scrollController.jumpTo(
        math.min(2 * step, _scrollController.position.maxScrollExtent),
      );
      if (mounted) setState(() => _focusedIndex = 2);
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _initialCenterApplied = false;
      _focusedIndex = 2;
      _error = null;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    await _loadNextPage();
  }

  double _gap(double width) => width >= 1500 ? 18 : 14;

  double _cardWidth(double width) {
    final padding = width >= 1500 ? 56.0 : 36.0;
    final gap = _gap(width);
    return math.max(150.0, (width - padding * 2 - gap * 4) / 5);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Vernieuwen',
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Laden mislukt: $_error'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadNextPage,
              child: const Text('Opnieuw'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return const Center(child: Text('Geen content gevonden.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = width >= 1500 ? 56.0 : 36.0;
        final gap = _gap(width);
        final baseWidth = _cardWidth(width);
        final baseHeight = baseWidth * 1.42;
        final step = baseWidth + gap;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 28),
            SizedBox(
              height: baseHeight + 56,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: padding),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final isMain = index == _focusedIndex.round();

                  return SizedBox(
                    width: step,
                    height: baseHeight + 40,
                    child: Center(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (_) => _focusItem(index, step),
                        child: AnimatedScale(
                          scale: isMain ? 1.10 : 1.0,
                          duration: const Duration(milliseconds: 140),
                          curve: Curves.easeOut,
                          child: _ContentCard(
                            item: _items[index],
                            width: baseWidth,
                            height: baseHeight,
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
    if (!_scrollController.hasClients) return;
    setState(() => _focusedIndex = index.toDouble());
    _scrollController.animateTo(
      ContentBrowserLayout.targetOffset(
        index: index,
        step: step,
        maxScrollExtent: _scrollController.position.maxScrollExtent,
      ),
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
    final imageUrl =
        '${item['public_url'] ?? metadata['public_url'] ?? metadata['image_url'] ?? ''}';

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

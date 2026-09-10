import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/chat_scope.dart';
import '../core/content_browser_layout.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/supabase_client.dart';
import 'chatbox.dart';
import 'content_detail_page.dart';

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
  final _searchController = TextEditingController();
  final _items = <ContentItem>[];
  bool _loading = false;
  bool _searching = false;
  bool _hasMore = true;
  bool _initialCenterApplied = false;
  int _page = 0;
  double _focusedIndex = 0;
  String? _error;
  String? _searchSource;

  bool get _isExternalSearch =>
      widget.contentType == 'game' ||
      widget.contentType == 'movie' ||
      widget.contentType == 'series';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final width = _scrollController.position.viewportDimension;
    final step = _cardWidth(width) + _gap(width);
    if (step > 0 && _items.isNotEmpty) {
      final nextFocus = ContentBrowserLayout.focusedIndex(
        offset: _scrollController.offset,
        step: step,
        itemCount: _items.length,
      ).toDouble();
      if (nextFocus != _focusedIndex && mounted) {
        setState(() => _focusedIndex = nextFocus);
      }
    }
    if (!_searching && _scrollController.position.maxScrollExtent -
            _scrollController.position.pixels < 1200) {
      _loadNextPage();
    }
  }

  Future<void> _loadNextPage() async {
    if (_loading || !_hasMore || _searching) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await _repository.getContentItemsPage(
        type: widget.contentType,
        page: _page,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _page++;
        _hasMore = page.length == ContentRepository.pageSize;
        _loading = false;
        if (_items.isNotEmpty) {
          _focusedIndex = _focusedIndex.clamp(0, _items.length - 1).toDouble();
        }
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

  Future<void> _searchExternal() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || !_isExternalSearch) return;

    final source = widget.contentType == 'game'
        ? 'igdb'
        : widget.contentType == 'movie'
            ? 'tmdb_movie'
            : 'tmdb_tv';

    FocusScope.of(context).unfocus();
    setState(() {
      _searching = true;
      _loading = true;
      _error = null;
      _searchSource = source == 'igdb' ? 'IGDB' : 'TMDB';
      _items.clear();
      _focusedIndex = 0;
      _hasMore = false;
      _initialCenterApplied = false;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);

    try {
      final response = await supabase.functions.invoke(
        'darkestworld-content-import',
        body: {'source': source, 'query': query},
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['ok'] != true) {
        throw Exception('${data['error'] ?? 'Zoeken mislukt.'}');
      }
      final rawItems = data['items'] is List ? data['items'] as List : const [];
      final results = <ContentItem>[];
      for (final raw in rawItems) {
        if (raw is! Map) continue;
        final row = Map<String, dynamic>.from(raw);
        final externalSource = '${row['external_source'] ?? source}'.trim();
        final externalId = '${row['external_id'] ?? ''}'.trim();
        row['id'] = '$externalSource:$externalId';
        final slug = '${row['slug'] ?? row['title'] ?? ''}'.trim();
        row['slug'] = slug.isEmpty ? '$externalSource-$externalId' : slug;
        try {
          results.add(ContentItem.fromRow(row));
        } catch (_) {
          // Ignore malformed external result instead of polluting the UI.
        }
      }
      if (!mounted) return;
      setState(() {
        _items.addAll(results);
        _loading = false;
        _searching = true;
        _focusedIndex = 0;
      });
      _centerInitialMainIfReady();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _searching = true;
        _error = e.toString();
      });
    }
  }

  Future<void> _refresh() async {
    if (_searching) {
      _searchController.clear();
      setState(() {
        _items.clear();
        _searching = false;
        _searchSource = null;
        _error = null;
        _page = 0;
        _hasMore = true;
        _initialCenterApplied = false;
        _focusedIndex = 0;
      });
      if (_scrollController.hasClients) _scrollController.jumpTo(0);
      await _loadNextPage();
      return;
    }
    setState(() {
      _items.clear();
      _page = 0;
      _hasMore = true;
      _initialCenterApplied = false;
      _focusedIndex = 0;
      _error = null;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    await _loadNextPage();
  }

  void _centerInitialMainIfReady() {
    if (_initialCenterApplied || _items.isEmpty || !_scrollController.hasClients) return;
    _initialCenterApplied = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final width = _scrollController.position.viewportDimension;
      final step = _cardWidth(width) + _gap(width);
      final targetIndex = math.min(2, _items.length - 1);
      _scrollController.jumpTo(
        math.min(targetIndex * step, _scrollController.position.maxScrollExtent),
      );
      if (mounted) setState(() => _focusedIndex = targetIndex.toDouble());
    });
  }

  double _gap(double width) => width >= 1500 ? 18 : 14;

  double _cardWidth(double width) {
    final padding = width >= 1500 ? 56.0 : 36.0;
    final gap = _gap(width);
    return math.max(150.0, (width - padding * 2 - gap * 4) / 5);
  }

  ChatContext? get _chatContext {
    if (_searching) return null;

    ChatScope? scope;
    switch (widget.contentType) {
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
    final index = _focusedIndex.round();
    final item = index >= 0 && index < _items.length ? _items[index] : null;
    return ChatContext(scope: scope, contentId: item?.id, contentTitle: item?.title);
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
      floatingActionButton: _chatContext == null ? null : Chatbox(contextData: _chatContext!),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        if (_isExternalSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchExternal(),
                decoration: InputDecoration(
                  hintText: widget.contentType == 'game'
                      ? 'Zoek een game'
                      : widget.contentType == 'movie'
                          ? 'Zoek een film'
                          : 'Zoek een serie',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Zoeken',
                    onPressed: _loading ? null : _searchExternal,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
        if (_searching && _searchSource != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Live zoekresultaten via $_searchSource • niet opgeslagen',
              style: TextStyle(color: Colors.white.withValues(alpha: .42), fontSize: 11),
            ),
          ),
        Expanded(child: _buildResults()),
      ],
    );
  }

  Widget _buildResults() {
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Laden mislukt: $_error'),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: _searching ? _searchExternal : _loadNextPage, child: const Text('Opnieuw')),
          ],
        ),
      );
    }
    if (_items.isEmpty && _loading) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) {
      return Center(
        child: Text(_searching ? 'Geen resultaten gevonden.' : 'Geen content gevonden.'),
      );
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
            const SizedBox(height: 20),
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
                        child: GestureDetector(
                          onTap: () => _openDetail(_items[index]),
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
                    ),
                  );
                },
              ),
            ),
            if (_loading)
              const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            if (!_searching && !_hasMore && !_loading)
              const Padding(padding: EdgeInsets.only(top: 8), child: Center(child: Text('Einde van de collectie'))),
          ],
        );
      },
    );
  }

  void _openDetail(ContentItem item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));
  }

  void _focusItem(int index, double step) {
    if (!_scrollController.hasClients) return;
    final safeIndex = index.clamp(0, _items.length - 1);
    setState(() => _focusedIndex = safeIndex.toDouble());
    _scrollController.animateTo(
      ContentBrowserLayout.targetOffset(
        index: safeIndex,
        step: step,
        maxScrollExtent: _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }
}

class _ContentCard extends StatelessWidget {
  final ContentItem item;
  final double width;
  final double height;
  final bool highlighted;

  const _ContentCard({required this.item, required this.width, required this.height, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final title = item.title;
    final metadata = item.metadata;
    final imageUrl = '${metadata['public_url'] ?? metadata['image_url'] ?? ''}'.trim();
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: highlighted ? 2 : 1,
          color: highlighted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
        ),
        boxShadow: highlighted ? [const BoxShadow(blurRadius: 18, spreadRadius: 1)] : const [],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imageUrl.isNotEmpty
                ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _Placeholder(title: title))
                : _Placeholder(title: title),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
            child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500)),
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

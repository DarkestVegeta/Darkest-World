import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/chat_scope.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/supabase_client.dart';
import 'chatbox.dart';
import 'content_detail_page.dart';

class ContentBrowserPage extends StatefulWidget {
  final String? contentType;
  final String title;
  final List<int> platformIds;

  const ContentBrowserPage({super.key, required this.title, this.contentType, this.platformIds = const []});

  @override
  State<ContentBrowserPage> createState() => _ContentBrowserPageState();
}

class _ContentBrowserPageState extends State<ContentBrowserPage> {
  final _repository = ContentRepository();
  final _search = TextEditingController();
  final _items = <ContentItem>[];
  bool _loading = false;
  bool _searching = false;
  bool _hasMore = true;
  int _page = 0;
  int _focus = 0;
  String? _error;

  bool get _external => ['game', 'movie', 'series'].contains(widget.contentType);
  String get _source => widget.contentType == 'game' ? 'igdb' : widget.contentType == 'movie' ? 'tmdb_movie' : 'tmdb_tv';
  String get _displayTitle => widget.title.replaceFirst(RegExp(r'\s*•\s*GAMES\s*$', caseSensitive: false), '').trim();
  bool get _snesTestLibrary => widget.contentType == 'game' && _displayTitle.toUpperCase() == 'SNES';

  List<int> get _platformIds {
    if (widget.platformIds.isNotEmpty) return widget.platformIds;
    final t = widget.title.toUpperCase();
    if (t.contains('NINTENDO')) return [18, 19, 4, 21, 5, 41, 20, 37, 130];
    if (t.contains('SEGA')) return [29, 32, 23, 84, 107];
    if (t.contains('PLAYSTATION')) return [7, 8, 9, 48, 167];
    if (t.contains('XBOX')) return [11, 12, 49, 169];
    return [];
  }

  List<ContentItem> get _realSnesTestItems => [
    ['3 Ninjas Kick Back', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/3%20Ninjas%20kick%20back.png'],
    ['90 Minutes - European Prime Goal', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/90%20Minutes%20-%20European%20Prime%20Goal.png'],
    ['A.S.P. Air Strike Patrol', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/A.S.P.%20Air%20Strike%20Patrol.png'],
    ['AAAHH!!!! Real Monsters', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/AAAHH!!!!%20Real%20Monsters.png'],
    ['ABC Monday Night Football', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/ABC%20Monday%20Night%20fOOTBALL.png'],
    ['Accele Brid', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/Accele%20Brid.png'],
    ['ACME Animation Factory', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/ACME%20Animation%20Factory.png'],
    ['ActRaiser', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/actraiser.png'],
    ['ActRaiser 2', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/actraiser%202.png'],
    ['Advanced Dungeons Dragons. Eye of the Beholder', 'https://abmqcbfwdwzgapvgqifk.supabase.co/storage/v1/object/public/snes-sealed/Advanced%20Dungeons%20Dragons.%20Eye%20of%20the%20Beholder.png'],
  ].map((entry) => ContentItem.fromRow({
    'id': 'snes-sealed:${entry[0]}',
    'content_type': 'game',
    'title': entry[0],
    'slug': entry[0].toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'),
    'metadata': {'public_url': entry[1], 'source': 'Supabase', 'collection': 'SNES Sealed'},
  })).toList();

  @override
  void initState() {
    super.initState();
    if (_snesTestLibrary) {
      _items.addAll(_realSnesTestItems);
      _focus = _items.length > 2 ? 2 : 0;
      _hasMore = false;
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading || !_hasMore || _searching) return;
    setState(() => _loading = true);
    try {
      final rows = await _repository.getContentItemsPage(type: widget.contentType, page: _page);
      if (!mounted) return;
      setState(() {
        _items.addAll(rows);
        _page++;
        _hasMore = rows.length == ContentRepository.pageSize;
        _loading = false;
        if (_items.isNotEmpty && _focus >= _items.length) _focus = _items.length - 1;
      });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = '$e'; });
    }
  }

  Future<void> _searchExternal() async {
    final query = _search.text.trim();
    if (query.isEmpty || !_external) return;
    FocusScope.of(context).unfocus();
    setState(() { _searching = true; _loading = true; _error = null; _items.clear(); _focus = 0; });
    try {
      final response = await supabase.functions.invoke('darkestworld-content-import', body: {
        'source': _source,
        'query': query,
        'platformIds': _platformIds,
      });
      final data = Map<String, dynamic>.from(response.data as Map);
      if (data['ok'] != true) throw Exception('${data['error'] ?? 'Zoeken mislukt.'}');
      final results = <ContentItem>[];
      for (final raw in (data['items'] is List ? data['items'] as List : const [])) {
        if (raw is! Map) continue;
        final row = Map<String, dynamic>.from(raw);
        final src = '${row['external_source'] ?? _source}';
        final id = '${row['external_id'] ?? ''}';
        row['id'] = '$src:$id';
        row['slug'] = '${row['slug'] ?? row['title'] ?? '$src-$id'}';
        try { results.add(ContentItem.fromRow(row)); } catch (_) {}
      }
      if (mounted) setState(() { _items.addAll(results); _loading = false; _focus = results.isEmpty ? 0 : results.length > 2 ? 2 : results.length - 1; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = '$e'; });
    }
  }

  Future<void> _refresh() async {
    _search.clear();
    if (_snesTestLibrary) {
      setState(() { _items..clear()..addAll(_realSnesTestItems); _focus = 2; _error = null; });
      return;
    }
    setState(() { _items.clear(); _page = 0; _focus = 0; _hasMore = true; _searching = false; _error = null; });
    await _load();
  }

  void _open(ContentItem item) => Navigator.push(context, MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  void _move(int delta) {
    if (_items.isEmpty) return;
    final next = (_focus + delta).clamp(0, _items.length - 1);
    if (next == _focus) return;
    setState(() => _focus = next);
    if (next >= _items.length - 6 && !_snesTestLibrary) _load();
  }

  void _focusItem(int index) {
    if (index < 0 || index >= _items.length) return;
    setState(() => _focus = index);
    if (index >= _items.length - 6 && !_snesTestLibrary) _load();
  }

  List<ContentItem?> get _five => List<ContentItem?>.generate(5, (slot) {
    final index = _focus + slot - 2;
    return index >= 0 && index < _items.length ? _items[index] : null;
  });

  ChatContext? get _chatContext {
    final scope = switch (widget.contentType) {
      'game' => ChatScope.games,
      'movie' => ChatScope.movies,
      'series' => ChatScope.series,
      _ => null,
    };
    if (scope == null || _items.isEmpty) return null;
    final item = _items[_focus.clamp(0, _items.length - 1)];
    return ChatContext(scope: scope, contentId: item.id, contentTitle: item.title);
  }

  @override
  Widget build(BuildContext context) {
    final isGame = widget.contentType == 'game';
    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      floatingActionButton: _chatContext == null ? null : Chatbox(contextData: _chatContext!),
      body: Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: _BrowserSpacePainter())),
        SafeArea(child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Row(children: [
              IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
              const SizedBox(width: 5),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('GAME-WORLD', style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white.withValues(alpha: .22))),
                const SizedBox(height: 4),
                Text(isGame ? '${_displayTitle.toUpperCase()}  /  GAMES' : widget.title.toUpperCase(), style: const TextStyle(fontSize: 13, letterSpacing: 2.2, fontWeight: FontWeight.w500)),
              ])),
              Text('${_items.length}', style: TextStyle(fontSize: 9, letterSpacing: 1.8, color: Colors.white.withValues(alpha: .25))),
              const SizedBox(width: 5),
              IconButton(onPressed: _loading ? null : _refresh, icon: const Icon(Icons.refresh, size: 17)),
            ]),
          ),
          if (_external) Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchExternal(),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: widget.contentType == 'game' ? 'SEARCH GAME LIBRARY' : widget.contentType == 'movie' ? 'SEARCH FILMS' : 'SEARCH SERIES',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: IconButton(onPressed: _loading ? null : _searchExternal, icon: const Icon(Icons.arrow_forward, size: 18)),
                  filled: true,
                  fillColor: const Color(0xFF090912),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0x14222222))),
                  enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0x14222222))),
                ),
              ),
            ),
          ),
          if (_searching) Padding(padding: const EdgeInsets.only(top: 7), child: Text('LIVE ${_source.toUpperCase()}  •  NIET OPGESLAGEN', style: TextStyle(fontSize: 8, letterSpacing: 1.8, color: Colors.white.withValues(alpha: .34)))),
          if (_snesTestLibrary) Padding(padding: const EdgeInsets.only(top: 7), child: Text('SNES SEALED  •  SUPABASE TEST LIBRARY', style: TextStyle(fontSize: 8, letterSpacing: 1.8, color: Colors.white.withValues(alpha: .34)))),
          Expanded(child: _body()),
        ])),
        Positioned(left: 0, right: 0, bottom: 18, child: Column(children: [
          if (_items.isNotEmpty) Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: _focus > 0 ? () => _move(-1) : null, icon: const Icon(Icons.chevron_left, size: 18)),
            Text('PREVIOUS   |   CURRENT   |   NEXT', style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white.withValues(alpha: .28))),
            IconButton(onPressed: _focus < _items.length - 1 ? () => _move(1) : null, icon: const Icon(Icons.chevron_right, size: 18)),
          ]),
          const SizedBox(height: 2),
          if (_items.isNotEmpty) Text('${_focus + 1}  /  ${_items.length}  •  CURRENT', style: TextStyle(fontSize: 8, letterSpacing: 1.7, color: Colors.white.withValues(alpha: .20))),
        ])),
      ]),
    );
  }

  Widget _body() {
    if (_error != null && _items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Laden mislukt: $_error'), const SizedBox(height: 12), OutlinedButton(onPressed: _searching ? _searchExternal : _load, child: const Text('Opnieuw'))]));
    if (_items.isEmpty) return Center(child: _loading ? const CircularProgressIndicator() : Text(_searching ? 'Geen resultaten gevonden.' : 'Geen content gevonden.'));

    return LayoutBuilder(builder: (context, c) {
      final gap = c.maxWidth > 1500 ? 18.0 : 14.0;
      final card = math.max(150.0, (c.maxWidth - gap * 4 - 40) / 5);
      final height = card * 1.42;
      final cards = _five;
      return Center(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: List.generate(5, (slot) {
          final item = cards[slot];
          final current = slot == 2;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: gap / 2),
            child: SizedBox(width: card, height: height + 36, child: item == null ? const SizedBox.shrink() : Center(child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => _focusItem(_focus + slot - 2),
              child: GestureDetector(
                onTap: () => current ? _open(item) : _focusItem(_focus + slot - 2),
                child: AnimatedScale(scale: current ? 1.10 : 1.0, duration: const Duration(milliseconds: 140), child: _Card(item: item, width: card, height: height, main: current, position: slot - 2)),
              ),
            ))),
          );
        })),
      ));
    });
  }
}

class _Card extends StatelessWidget {
  final ContentItem item;
  final double width;
  final double height;
  final bool main;
  final int position;
  const _Card({required this.item, required this.width, required this.height, required this.main, required this.position});

  @override
  Widget build(BuildContext context) {
    final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}'.trim();
    final positionLabel = main ? 'CURRENT' : position < 0 ? 'PREVIOUS' : 'NEXT';
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(main ? 16 : 13),
        border: Border.all(width: main ? 2 : 1, color: main ? const Color(0xFF8E7BE8) : const Color(0x18222222)),
        boxShadow: main ? [const BoxShadow(color: Color(0x286956C7), blurRadius: 35, spreadRadius: 1)] : const [],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(child: url.isEmpty ? _Placeholder(title: item.title) : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _Placeholder(title: item.title))),
        Container(padding: const EdgeInsets.fromLTRB(12, 10, 12, 11), color: const Color(0xE6080810), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(positionLabel, style: TextStyle(fontSize: 7, letterSpacing: 1.8, color: Colors.white.withValues(alpha: main ? .48 : .20))),
          const SizedBox(height: 5),
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: main ? FontWeight.w700 : FontWeight.w500, fontSize: main ? 12 : 11)),
        ])),
      ]),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});
  @override
  Widget build(BuildContext context) => Container(color: const Color(0xFF0A0913), child: Center(child: Padding(padding: const EdgeInsets.all(18), child: Text(title, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .55))))));
}

class _BrowserSpacePainter extends CustomPainter {
  const _BrowserSpacePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = const RadialGradient(center: Alignment(0, -.18), radius: 1.15, colors: [Color(0xFF17142D), Color(0xFF070712), Color(0xFF010105)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);
    final glow = Paint()..color = const Color(0xFF7866D8).withValues(alpha: .035)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 110);
    canvas.drawCircle(Offset(size.width / 2, size.height * .48), 280, glow);
    final random = math.Random(811);
    final star = Paint();
    for (var i = 0; i < 150; i++) {
      star.color = Colors.white.withValues(alpha: .08 + (i % 6) * .022);
      canvas.drawCircle(Offset(random.nextDouble() * size.width, random.nextDouble() * size.height), i % 23 == 0 ? .85 : .34, star);
    }
  }
  @override
  bool shouldRepaint(covariant _BrowserSpacePainter oldDelegate) => false;
}

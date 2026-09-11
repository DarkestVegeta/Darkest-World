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
  @override State<ContentBrowserPage> createState() => _ContentBrowserPageState();
}

class _ContentBrowserPageState extends State<ContentBrowserPage> {
  final _repository = ContentRepository();
  final _items = <ContentItem>[];
  bool _loading = false;
  bool _hasMore = true;
  int _page = 0;
  int _focus = 0;
  String? _error;

  // All content is now user's own DarkestWorld library. No IGDB/TMDB search or imports.
  bool get _snesLibrary => widget.contentType == 'game' && (widget.platformIds.contains(19) || _displayTitle.toUpperCase() == 'SNES');
  String get _displayTitle => widget.title.replaceFirst(RegExp(r'\s*•\s*GAMES\s*$', caseSensitive: false), '').trim();

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { super.dispose(); }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() { _loading = true; _error = null; });
    try {
      final rows = _snesLibrary
          ? await supabase.from('storage_assets').select('id,title,public_url,metadata').eq('asset_type', 'snes_sealed').not('public_url', 'is', null).neq('public_url', '').order('title').limit(1000)
          : await _repository.getContentItemsPage(type: widget.contentType, page: _page);
      final loaded = _snesLibrary ? <ContentItem>[for (final raw in rows) if (raw is Map) _snesItem(Map<String, dynamic>.from(raw))] : List<ContentItem>.from(rows);
      if (!mounted) return;
      setState(() {
        _items.addAll(loaded);
        _page++;
        _hasMore = _snesLibrary ? false : loaded.length == ContentRepository.pageSize;
        _loading = false;
        if (_items.isNotEmpty && _focus >= _items.length) _focus = _items.length - 1;
      });
    } catch (e) { if (mounted) setState(() { _loading = false; _error = '$e'; }); }
  }

  ContentItem _snesItem(Map<String, dynamic> row) {
    final rawMetadata = row['metadata'];
    final metadata = rawMetadata is Map ? Map<String, dynamic>.from(rawMetadata) : <String, dynamic>{};
    metadata['public_url'] = row['public_url'];
    metadata['source'] = 'Supabase';
    metadata['collection'] = 'SNES Sealed';
    final title = '${row['title'] ?? 'Untitled'}'.trim();
    return ContentItem.fromRow({'id': 'snes-sealed:${row['id']}', 'content_type': 'game', 'title': title, 'slug': title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), ''), 'metadata': metadata});
  }

  Future<void> _refresh() async {
    setState(() { _items.clear(); _page = 0; _focus = 0; _hasMore = true; _error = null; });
    await _load();
  }

  void _open(ContentItem item) => Navigator.push(context, MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));
  void _move(int delta) { if (_items.isEmpty) return; final next = (_focus + delta).clamp(0, _items.length - 1); if (next == _focus) return; setState(() => _focus = next); if (next >= _items.length - 6 && !_snesLibrary) _load(); }
  void _focusItem(int index) { if (index < 0 || index >= _items.length) return; setState(() => _focus = index); if (index >= _items.length - 6 && !_snesLibrary) _load(); }
  List<ContentItem?> get _five => List.generate(5, (slot) { final index = _focus + slot - 2; return index >= 0 && index < _items.length ? _items[index] : null; });

  ChatContext? get _chatContext {
    final scope = switch (widget.contentType) { 'game' => ChatScope.games, 'movie' => ChatScope.movies, 'series' => ChatScope.series, _ => null };
    if (scope == null || _items.isEmpty) return null;
    final item = _items[_focus.clamp(0, _items.length - 1)];
    return ChatContext(scope: scope, contentId: item.id, contentTitle: item.title);
  }

  @override
  Widget build(BuildContext context) {
    final typeLabel = widget.contentType == 'game' ? '${_displayTitle.toUpperCase()}  /  GAMES' : widget.contentType == 'movie' ? '${widget.title.toUpperCase()}  /  FILMS' : '${widget.title.toUpperCase()}  /  SERIES';
    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      floatingActionButton: _chatContext == null ? null : Chatbox(contextData: _chatContext!),
      body: Stack(children: [
        const Positioned.fill(child: CustomPaint(painter: _BrowserSpacePainter())),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 0), child: Row(children: [
            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)), const SizedBox(width: 5),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DARKEST-WORLD', style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white.withValues(alpha: .22))), const SizedBox(height: 4), Text(typeLabel, style: const TextStyle(fontSize: 13, letterSpacing: 2.2, fontWeight: FontWeight.w500))])),
            Text('${_items.length}', style: TextStyle(fontSize: 9, letterSpacing: 1.8, color: Colors.white.withValues(alpha: .25))), const SizedBox(width: 5), IconButton(onPressed: _loading ? null : _refresh, icon: const Icon(Icons.refresh, size: 17)),
          ])),
          if (_snesLibrary) Padding(padding: const EdgeInsets.only(top: 7), child: Text('SNES SEALED  •  SUPABASE LIBRARY', style: TextStyle(fontSize: 8, letterSpacing: 1.8, color: Colors.white.withValues(alpha: .34)))),
          Expanded(child: _body()),
        ])),
        Positioned(left: 0, right: 0, bottom: 18, child: Column(children: [
          if (_items.isNotEmpty) Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(onPressed: _focus > 0 ? () => _move(-1) : null, icon: const Icon(Icons.chevron_left, size: 18)), Text('PREVIOUS   |   CURRENT   |   NEXT', style: TextStyle(fontSize: 8, letterSpacing: 2.4, color: Colors.white.withValues(alpha: .28))), IconButton(onPressed: _focus < _items.length - 1 ? () => _move(1) : null, icon: const Icon(Icons.chevron_right, size: 18))]),
          const SizedBox(height: 2), if (_items.isNotEmpty) Text('${_focus + 1}  /  ${_items.length}  •  CURRENT', style: TextStyle(fontSize: 8, letterSpacing: 1.7, color: Colors.white.withValues(alpha: .20))),
        ])),
      ]),
    );
  }

  Widget _body() {
    if (_error != null && _items.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text('Laden mislukt: $_error'), const SizedBox(height: 12), OutlinedButton(onPressed: _load, child: const Text('Opnieuw'))]));
    if (_items.isEmpty) return Center(child: _loading ? const CircularProgressIndicator() : const Text('Geen content gevonden.'));
    return LayoutBuilder(builder: (context, c) {
      final gap = c.maxWidth > 1500 ? 18.0 : 14.0;
      final card = math.max(150.0, (c.maxWidth - gap * 4 - 40) / 5);
      final height = card * 1.42;
      final cards = _five;
      return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (slot) {
        final item = cards[slot]; final current = slot == 2;
        return Padding(padding: EdgeInsets.symmetric(horizontal: gap / 2), child: SizedBox(width: card, height: height + 36, child: item == null ? const SizedBox.shrink() : Center(child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => _focusItem(_focus + slot - 2), child: GestureDetector(onTap: () => current ? _open(item) : _focusItem(_focus + slot - 2), child: AnimatedScale(scale: current ? 1.10 : 1.0, duration: const Duration(milliseconds: 140), child: _Card(item: item, width: card, height: height, main: current, position: slot - 2))))));
      }))));
    });
  }
}

class _Card extends StatelessWidget {
  final ContentItem item; final double width; final double height; final bool main; final int position;
  const _Card({required this.item, required this.width, required this.height, required this.main, required this.position});
  @override Widget build(BuildContext context) {
    final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}'.trim();
    final positionLabel = main ? 'CURRENT' : position < 0 ? 'PREVIOUS' : 'NEXT';
    return Container(width: width, height: height, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: const Color(0xFF090912), borderRadius: BorderRadius.circular(main ? 16 : 13), border: Border.all(width: main ? 2 : 1, color: main ? const Color(0xFF8E7BE8) : const Color(0x18222222)), boxShadow: main ? [const BoxShadow(color: Color(0x286956C7), blurRadius: 35, spreadRadius: 1)] : const []), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Expanded(child: url.isEmpty ? _Placeholder(title: item.title) : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _Placeholder(title: item.title))), Container(padding: const EdgeInsets.fromLTRB(12, 10, 12, 11), color: const Color(0xE6080810), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(positionLabel, style: TextStyle(fontSize: 7, letterSpacing: 1.8, color: Colors.white.withValues(alpha: main ? .48 : .20))), const SizedBox(height: 5), Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: main ? FontWeight.w700 : FontWeight.w500, fontSize: main ? 12 : 11))]))]));
  }
}

class _Placeholder extends StatelessWidget { final String title; const _Placeholder({required this.title}); @override Widget build(BuildContext context) => Container(color: const Color(0xFF0A0913), child: Center(child: Padding(padding: const EdgeInsets.all(18), child: Text(title, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .55)))))); }

class _BrowserSpacePainter extends CustomPainter {
  const _BrowserSpacePainter();
  @override void paint(Canvas canvas, Size size) {
    final bg = Paint()..shader = const RadialGradient(center: Alignment(0, -.18), radius: 1.15, colors: [Color(0xFF17142D), Color(0xFF070712), Color(0xFF010105)]).createShader(Offset.zero & size); canvas.drawRect(Offset.zero & size, bg);
    final random = math.Random(2307); final stars = Paint()..color = Colors.white;
    for (var i = 0; i < 240; i++) { final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height); final r = random.nextDouble() * 1.15 + .15; stars.color = Colors.white.withValues(alpha: random.nextDouble() * .28 + .05); canvas.drawCircle(p, r, stars); }
    final haze = Paint()..shader = RadialGradient(center: const Alignment(0, -.25), radius: .9, colors: [const Color(0x241E1A55), Colors.transparent]).createShader(Offset.zero & size); canvas.drawRect(Offset.zero & size, haze);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

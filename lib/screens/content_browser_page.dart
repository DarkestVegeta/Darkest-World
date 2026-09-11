import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/supabase_client.dart';
import 'content_detail_page.dart';

class ContentBrowserPage extends StatefulWidget {
  final String? contentType;
  final String title;
  final List<int> platformIds;
  const ContentBrowserPage({super.key, required this.title, this.contentType, this.platformIds = const []});
  @override State<ContentBrowserPage> createState() => _ContentBrowserPageState();
}

class _ContentBrowserPageState extends State<ContentBrowserPage> {
  final repository = ContentRepository();
  final items = <ContentItem>[];
  bool loading = false;
  bool hasMore = true;
  int page = 0;
  int focus = 0;
  String? error;

  bool get snesLibrary => widget.contentType == 'game' && (widget.platformIds.contains(19) || widget.title.toUpperCase().contains('SNES'));
  String get displayTitle => widget.title.replaceFirst(RegExp(r'\s*•\s*GAMES\s*$', caseSensitive: false), '').trim();

  @override void initState() { super.initState(); load(); }
  Future<void> load() async {
    if (loading || !hasMore) return;
    setState(() { loading = true; error = null; });
    try {
      List<ContentItem> loaded;
      if (snesLibrary) {
        final rows = await supabase.from('storage_assets').select('id,title,public_url,metadata').eq('asset_type', 'snes_sealed').not('public_url', 'is', null).neq('public_url', '').order('title').limit(1000);
        loaded = [for (final row in rows) _snesItem(Map<String, dynamic>.from(row))];
      } else {
        loaded = await repository.getContentItemsPage(type: widget.contentType, page: page);
      }
      if (!mounted) return;
      setState(() { items.addAll(loaded); page++; hasMore = snesLibrary ? false : loaded.length == ContentRepository.pageSize; loading = false; });
    } catch (e) { if (mounted) setState(() { loading = false; error = '$e'; }); }
  }

  ContentItem _snesItem(Map<String, dynamic> row) {
    final meta = row['metadata'] is Map ? Map<String, dynamic>.from(row['metadata']) : <String, dynamic>{};
    meta['public_url'] = row['public_url']; meta['source'] = 'Supabase'; meta['collection'] = 'SNES Sealed';
    final title = '${row['title'] ?? 'Untitled'}'.trim();
    return ContentItem.fromRow({'id': 'snes-sealed:${row['id']}', 'content_type': 'game', 'title': title, 'slug': title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-'), 'metadata': meta});
  }

  Future<void> refresh() async { setState(() { items.clear(); page = 0; focus = 0; hasMore = true; error = null; }); await load(); }
  void open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));
  void move(int delta) { if (items.isEmpty) return; final next = (focus + delta).clamp(0, items.length - 1); if (next != focus) setState(() => focus = next); if (next >= items.length - 6) load(); }

  @override
  Widget build(BuildContext context) {
    final label = widget.contentType == 'game' ? '${displayTitle.toUpperCase()} / GAMES' : widget.contentType == 'movie' ? '${widget.title.toUpperCase()} / FILMS' : '${widget.title.toUpperCase()} / SERIES';
    return Scaffold(backgroundColor: const Color(0xFF010107), body: Stack(children: [
      const Positioned.fill(child: CustomPaint(painter: _ContentBackgroundPainter())),
      SafeArea(child: Column(children: [Padding(padding: const EdgeInsets.all(16), child: Row(children: [IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)), Expanded(child: Text(label, style: const TextStyle(fontSize: 12, letterSpacing: 2))), Text('${items.length}', style: TextStyle(fontSize: 9, color: Colors.white.withValues(alpha: .25))), IconButton(onPressed: loading ? null : refresh, icon: const Icon(Icons.refresh, size: 17))])), if (snesLibrary) Text('SNES SEALED  •  SUPABASE LIBRARY', style: TextStyle(fontSize: 8, letterSpacing: 1.8, color: Colors.white.withValues(alpha: .32))), Expanded(child: body())])),
      Positioned(left: 0, right: 0, bottom: 18, child: Column(children: [if (items.isNotEmpty) Row(mainAxisAlignment: MainAxisAlignment.center, children: [IconButton(onPressed: focus > 0 ? () => move(-1) : null, icon: const Icon(Icons.chevron_left)), Text('PREVIOUS   |   CURRENT   |   NEXT', style: TextStyle(fontSize: 8, letterSpacing: 2.2, color: Colors.white.withValues(alpha: .25))), IconButton(onPressed: focus < items.length - 1 ? () => move(1) : null, icon: const Icon(Icons.chevron_right))]), if (items.isNotEmpty) Text('${focus + 1} / ${items.length}', style: TextStyle(fontSize: 8, color: Colors.white.withValues(alpha: .18)))])),
    ]));
  }

  Widget body() {
    if (error != null && items.isEmpty) return Center(child: Text('Laden mislukt: $error'));
    if (items.isEmpty) return Center(child: loading ? const CircularProgressIndicator() : const Text('Geen content gevonden.'));
    final start = math.max(0, math.min(focus - 2, items.length - 5));
    final end = math.min(items.length, start + 5);
    final visible = items.sublist(start, end);
    return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [for (var i = 0; i < visible.length; i++) Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: GestureDetector(onTap: () { final index = start + i; if (index == focus) open(items[index]); else setState(() => focus = index); }, child: _Card(item: visible[i], main: start + i == focus)))])));
  }
}

class _Card extends StatelessWidget {
  final ContentItem item; final bool main;
  const _Card({required this.item, required this.main});
  @override Widget build(BuildContext context) { final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}'.trim(); return SizedBox(width: main ? 245 : 190, height: main ? 365 : 300, child: Container(decoration: BoxDecoration(color: const Color(0xFF090912), borderRadius: BorderRadius.circular(main ? 16 : 12), border: Border.all(color: Colors.white.withValues(alpha: main ? .20 : .07))), clipBehavior: Clip.antiAlias, child: Column(children: [Expanded(child: url.isEmpty ? _Placeholder(title: item.title) : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _Placeholder(title: item.title))), Padding(padding: const EdgeInsets.all(11), child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: main ? 12 : 10, fontWeight: main ? FontWeight.w600 : FontWeight.w400)))]))); }
}
class _Placeholder extends StatelessWidget { final String title; const _Placeholder({required this.title}); @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(title, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .55))))); }
class _ContentBackgroundPainter extends CustomPainter { const _ContentBackgroundPainter(); @override void paint(Canvas c, Size s) { c.drawRect(Offset.zero & s, Paint()..shader = const RadialGradient(colors: [Color(0xFF17142D), Color(0xFF070712), Color(0xFF010105)]).createShader(Offset.zero & s)); } @override bool shouldRepaint(covariant _ContentBackgroundPainter old) => false; }

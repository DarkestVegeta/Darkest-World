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

class _ContentBrowserPageState extends State<ContentBrowserPage> with SingleTickerProviderStateMixin {
  final repository = ContentRepository();
  final items = <ContentItem>[];
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 28))..repeat();
  bool loading = false;
  bool hasMore = true;
  int page = 0;
  int focus = 0;
  String query = '';
  String? error;

  bool get snesLibrary => widget.contentType == 'game' && (widget.platformIds.contains(19) || widget.title.toUpperCase().contains('SNES'));
  String get displayTitle => widget.title.replaceFirst(RegExp(r'\s*•\s*GAMES\s*$', caseSensitive: false), '').trim();
  List<ContentItem> get filtered => query.trim().isEmpty ? items : items.where((x) => x.title.toLowerCase().contains(query.trim().toLowerCase())).toList();

  @override void initState() { super.initState(); load(); }
  @override void dispose() { clock.dispose(); super.dispose(); }

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
  void move(int delta) { if (filtered.isEmpty) return; final next = (focus + delta).clamp(0, filtered.length - 1); if (next != focus) setState(() => focus = next); if (next >= filtered.length - 6) load(); }
  void setQuery(String value) { setState(() { query = value; focus = 0; }); }
  void open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  @override Widget build(BuildContext context) {
    final label = widget.contentType == 'game' ? '${displayTitle.toUpperCase()} / GAMES' : widget.contentType == 'movie' ? '${widget.title.toUpperCase()} / FILMS' : '${widget.title.toUpperCase()} / SERIES';
    final visibleCount = filtered.length;
    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _ContentBackgroundPainter(t: clock.value))),
        SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [
            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new, size: 16)),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, letterSpacing: 2))),
            if (!snesLibrary) SizedBox(width: 190, height: 32, child: TextField(onChanged: setQuery, style: const TextStyle(fontSize: 10), decoration: InputDecoration(hintText: 'SEARCH ARCHIVE', hintStyle: const TextStyle(fontSize: 7, letterSpacing: 1.8, color: Colors.white24), prefixIcon: const Icon(Icons.search, size: 14, color: Colors.white30), filled: true, fillColor: const Color(0x440A0912), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: .07))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: .07))))))),
            const SizedBox(width: 14),
            _Meta(label: 'VISIBLE', value: '$visibleCount'), const SizedBox(width: 18),
            IconButton(onPressed: loading ? null : refresh, icon: const Icon(Icons.refresh, size: 17)),
          ])),
          if (snesLibrary) const Text('SNES SEALED  •  SUPABASE LIBRARY', style: TextStyle(fontSize: 8, letterSpacing: 1.8, color: Colors.white38)),
          const SizedBox(height: 4),
          Expanded(child: body()),
        ])),
        Positioned(left: 18, right: 18, bottom: 16, child: _ArchiveBar(focus: focus, count: filtered.length, current: filtered.isEmpty ? '—' : filtered[focus.clamp(0, filtered.length - 1)].title, onPrevious: focus > 0 ? () => move(-1) : null, onNext: focus < filtered.length - 1 ? () => move(1) : null)),
      ])),
    );
  }

  Widget body() {
    if (error != null && items.isEmpty) return Center(child: Text('Laden mislukt: $error'));
    if (items.isEmpty) return Center(child: loading ? const CircularProgressIndicator() : const Text('Geen content gevonden.'));
    if (filtered.isEmpty) return const Center(child: Text('GEEN RESULTATEN', style: TextStyle(fontSize: 9, letterSpacing: 3, color: Colors.white38)));
    final start = math.max(0, math.min(focus - 2, filtered.length - 5));
    final end = math.min(filtered.length, start + 5);
    final visible = filtered.sublist(start, end);
    return Center(child: Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 72), child: Column(children: [
      const SizedBox(height: 8),
      Text('ARCHIVE / FOCUS BROWSE', style: TextStyle(fontSize: 7, letterSpacing: 3, color: Colors.white.withValues(alpha: .22))),
      const SizedBox(height: 18),
      Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
        for (var i = 0; i < visible.length; i++) Padding(padding: const EdgeInsets.symmetric(horizontal: 6), child: GestureDetector(onTap: () { final index = start + i; if (index == focus) open(filtered[index]); else setState(() => focus = index); }, child: _Card(item: visible[i], main: start + i == focus, index: start + i, t: clock.value))),
      ])),
    ])));
  }
}

class _Meta extends StatelessWidget { final String label, value; const _Meta({required this.label, required this.value}); @override Widget build(BuildContext c) => Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(label, style: const TextStyle(fontSize: 6, letterSpacing: 2, color: Colors.white24)), const SizedBox(height: 3), Text(value, style: const TextStyle(fontSize: 9, letterSpacing: 1.2, color: Colors.white54))]); }

class _Card extends StatelessWidget {
  final ContentItem item; final bool main; final int index; final double t;
  const _Card({required this.item, required this.main, required this.index, required this.t});
  @override Widget build(BuildContext context) {
    final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}'.trim();
    return AnimatedContainer(duration: const Duration(milliseconds: 260), width: main ? 260 : 190, height: main ? 390 : 300, transform: Matrix4.identity()..scale(main ? 1.0 : .96), transformAlignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFF07070F), borderRadius: BorderRadius.circular(main ? 19 : 13), border: Border.all(color: Colors.white.withValues(alpha: main ? .24 : .07), width: main ? 1.3 : .8), boxShadow: main ? const [BoxShadow(color: Color(0x557765D0), blurRadius: 42), BoxShadow(color: Color(0x99000000), blurRadius: 30, offset: Offset(0, 16))] : const []), clipBehavior: Clip.antiAlias, child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _CardAtmosphere(active: main, seed: index, t: t))),
      Positioned.fill(child: Padding(padding: const EdgeInsets.all(1), child: Column(children: [
        Expanded(child: url.isEmpty ? _Placeholder(title: item.title) : Image.network(url, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => _Placeholder(title: item.title))),
        Container(padding: EdgeInsets.fromLTRB(main ? 14 : 10, 12, main ? 14 : 10, 13), decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF151326), Color(0xFF07070D)])), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(main ? 'CURRENT' : 'ARCHIVE', style: const TextStyle(fontSize: 6, letterSpacing: 2, color: Colors.white30)), const SizedBox(height: 5), Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: main ? 12 : 10, letterSpacing: main ? .6 : .3, fontWeight: main ? FontWeight.w600 : FontWeight.w400)),])), Text('${(index + 1).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 7, letterSpacing: 1.5, color: Colors.white24))]))
      ]))),
      if (main) Positioned(top: 12, right: 12, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5), decoration: BoxDecoration(color: const Color(0xAA090812), borderRadius: BorderRadius.circular(7), border: Border.all(color: Colors.white.withValues(alpha: .08))), child: const Text('ENTER', style: TextStyle(fontSize: 6, letterSpacing: 1.7, color: Colors.white54)))),
    ]));
  }
}

class _Placeholder extends StatelessWidget { final String title; const _Placeholder({required this.title}); @override Widget build(BuildContext context) => Container(decoration: const BoxDecoration(gradient: RadialGradient(colors: [Color(0xFF30284B), Color(0xFF090811)])), child: Center(child: Padding(padding: const EdgeInsets.all(18), child: Text(title, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white54))))); }

class _CardAtmosphere extends CustomPainter { final bool active; final int seed; final double t; const _CardAtmosphere({required this.active, required this.seed, required this.t}); @override void paint(Canvas c, Size s) { final r = math.Random(seed + 71); final p = Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1 : .55..color = Colors.white.withValues(alpha: active ? .045 : .022); for (var k = 0; k < 4; k++) { final rect = Rect.fromCenter(center: Offset(s.width * (.55 + math.sin(t * math.pi * 2 + seed) * .025), s.height * .38), width: s.width * (.32 + k * .18), height: s.height * (.12 + k * .10)); c.drawOval(rect, p); } for (var i = 0; i < 18; i++) { final x = r.nextDouble() * s.width; final y = r.nextDouble() * s.height * .76; c.drawCircle(Offset(x, y), .25 + r.nextDouble() * .6, Paint()..color = Colors.white.withValues(alpha: active ? .025 : .012)); } } @override bool shouldRepaint(covariant _CardAtmosphere old) => old.t != t || old.active != active; }

class _ArchiveBar extends StatelessWidget { final int focus, count; final String current; final VoidCallback? onPrevious, onNext; const _ArchiveBar({required this.focus, required this.count, required this.current, required this.onPrevious, required this.onNext}); @override Widget build(BuildContext c) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xDD07070E), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: .07)), boxShadow: const [BoxShadow(color: Color(0x88000000), blurRadius: 25, offset: Offset(0, 8))]), child: Row(children: [IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left, size: 18)), Expanded(child: Column(children: [Text('CURRENT ARCHIVE ITEM', style: const TextStyle(fontSize: 5, letterSpacing: 2.2, color: Colors.white24)), const SizedBox(height: 3), Text(current, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, letterSpacing: 1.2, color: Colors.white70)), const SizedBox(height: 3), Text(count == 0 ? '00 / 00' : '${(focus + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 6, letterSpacing: 2, color: Colors.white24))])), IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right, size: 18))])); }

class _ContentBackgroundPainter extends CustomPainter { final double t; const _ContentBackgroundPainter({required this.t}); @override void paint(Canvas c, Size s) { final rect = Offset.zero & s; c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.15), radius: 1.15, colors: [Color(0xFF1B1734), Color(0xFF070712), Color(0xFF010105)]).createShader(rect)); final r = math.Random(914); for (var i = 0; i < 280; i++) { final x = (r.nextDouble() * s.width + t * s.width * .018) % s.width; final y = (r.nextDouble() * s.height + math.sin(t * math.pi * 2 + i) * 2) % s.height; c.drawCircle(Offset(x, y), .15 + r.nextDouble() * .7, Paint()..color = Colors.white.withValues(alpha: .012 + r.nextDouble() * .05)); } for (var i = 0; i < 5; i++) { final p = Offset(s.width * (.12 + i * .20) + math.sin(t * math.pi * 2 + i) * 20, s.height * (.18 + (i % 3) * .27)); c.drawCircle(p, 80 + i * 26.0, Paint()..color = const Color(0x078F82B5)); } c.drawOval(Rect.fromCenter(center: Offset(s.width * .5, s.height * .5), width: s.width * .72, height: s.height * .82), Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x0E9A8CC0)); } @override bool shouldRepaint(covariant _ContentBackgroundPainter old) => old.t != t; }

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/darkest_world_navigation_state.dart';
import '../core/supabase_client.dart';
import 'content_detail_page.dart';
import 'galaxy_navigation_session.dart';

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
  final navigation = GalaxyNavigationSession.instance;
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 80))..repeat();
  bool loading = true;
  String query = '';
  int selected = 0;

  bool get snes => widget.contentType == 'game' && (widget.platformIds.contains(19) || widget.title.toUpperCase().contains('SNES'));

  @override void initState() { super.initState(); load(); }
  @override void dispose() { clock.dispose(); super.dispose(); }

  List<ContentItem> get _shown => items.where((x) => query.isEmpty || x.title.toLowerCase().contains(query.toLowerCase())).toList();

  void _publishSelection(List<ContentItem> shown) {
    if (shown.isEmpty) { navigation.clearContentNavigation(); return; }
    if (selected >= shown.length) selected = shown.length - 1;
    navigation.publishContentNavigation(DarkestWorldNavigationState(
      previous: selected > 0 ? shown[selected - 1] : null,
      current: shown[selected],
      next: selected + 1 < shown.length ? shown[selected + 1] : null,
      related: const [], source: 'archive',
    ));
  }

  void _setSelected(int index) {
    final shown = _shown; if (shown.isEmpty) return;
    setState(() => selected = index.clamp(0, shown.length - 1)); _publishSelection(shown);
  }

  void _openSelected() { final shown = _shown; if (shown.isEmpty) return; open(shown[selected.clamp(0, shown.length - 1)]); }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final shown = _shown; if (shown.isEmpty) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) { _setSelected(selected - 1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) { _setSelected(selected + 1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.enter) { _openSelected(); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  Future<void> load() async {
    try {
      List<ContentItem> result;
      if (snes) {
        final rows = await supabase.from('storage_assets').select('id,title,public_url,metadata').eq('asset_type','snes_sealed').not('public_url','is',null).neq('public_url','').order('title').limit(1000);
        result = [for (final row in rows) _snes(Map<String, dynamic>.from(row))];
      } else {
        result = await repository.getContentItemsPage(type: widget.contentType, page: 0);
      }
      if (!mounted) return;
      setState(() { items.addAll(result); loading = false; }); _publishSelection(_shown);
    } catch (_) {
      if (mounted) { setState(() => loading = false); navigation.clearContentNavigation(); }
    }
  }

  ContentItem _snes(Map<String, dynamic> row) {
    final meta = row['metadata'] is Map ? Map<String, dynamic>.from(row['metadata']) : <String, dynamic>{};
    meta['public_url'] = row['public_url'];
    return ContentItem.fromRow({'id': 'snes:${row['id']}', 'content_type': 'game', 'title': '${row['title'] ?? 'Untitled'}', 'slug': 'snes-${row['id']}', 'metadata': meta});
  }

  void open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  @override Widget build(BuildContext context) {
    final shown = _shown; if (selected >= shown.length) selected = shown.isEmpty ? 0 : shown.length - 1;
    final compact = MediaQuery.sizeOf(context).width < 850;
    return Focus(autofocus: true, onKeyEvent: _handleKey, child: Scaffold(
      backgroundColor: const Color(0xFF010107),
      body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _ArchivePainter(clock.value))),
        SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(compact ? 12 : 30, compact ? 10 : 20, compact ? 12 : 30, 12), child: Column(children: [
          _TopBar(title: widget.title, compact: compact, onBack: () => Navigator.pop(context), onSearch: (v) { query = v; selected = 0; setState(() {}); _publishSelection(_shown); }),
          const SizedBox(height: 16),
          Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : shown.isEmpty ? const _EmptyArchive() : ListView(physics: const BouncingScrollPhysics(), children: [
            _HeroArchive(items: shown, selected: selected, compact: compact, onSelect: _setSelected, onOpen: open),
            const SizedBox(height: 24), _SectionHeader(count: shown.length, query: query), const SizedBox(height: 10),
            _ArchiveGrid(items: shown, compact: compact, selected: selected, onSelect: _setSelected, onOpen: open),
          ])),
        ]))),
      ])),
    ));
  }
}

class _TopBar extends StatelessWidget {
  final String title; final bool compact; final VoidCallback onBack; final ValueChanged<String> onSearch;
  const _TopBar({required this.title, required this.compact, required this.onBack, required this.onSearch});
  @override Widget build(BuildContext context) => Row(children: [
    IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new, size: 15, color: Color(0xBFFFFFFF))), const SizedBox(width: 5),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 2.8)), const SizedBox(height: 4), const Text('DARK CORE / PHYSICAL MEDIA ARCHIVE', style: TextStyle(fontSize: 6.5, letterSpacing: 2, color: Color(0x55FFFFFF)))])),
    SizedBox(width: compact ? 150 : 260, height: 34, child: TextField(onChanged: onSearch, style: const TextStyle(fontSize: 10, color: Colors.white), decoration: const InputDecoration(hintText: 'SEARCH ARCHIVE', hintStyle: TextStyle(fontSize: 8, color: Color(0x55FFFFFF)), prefixIcon: Icon(Icons.search, size: 14, color: Color(0x88FFFFFF)), filled: true, fillColor: Color(0x660A0B14), border: OutlineInputBorder(borderSide: BorderSide(color: Color(0x227F70B0))), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x227F70B0))))))
  ]);
}

class _HeroArchive extends StatelessWidget {
  final List<ContentItem> items; final int selected; final bool compact; final ValueChanged<int> onSelect; final ValueChanged<ContentItem> onOpen;
  const _HeroArchive({required this.items, required this.selected, required this.compact, required this.onSelect, required this.onOpen});
  @override Widget build(BuildContext context) {
    final current = items[selected], previous = selected > 0 ? items[selected - 1] : null, next = selected + 1 < items.length ? items[selected + 1] : null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: _Neighbor(item: previous, label: 'PREVIOUS', compact: compact, onTap: previous == null ? null : () => onSelect(selected - 1))), const SizedBox(width: 10), Expanded(flex: 2, child: _Current(item: current, compact: compact, onOpen: () => onOpen(current))), const SizedBox(width: 10), Expanded(child: _Neighbor(item: next, label: 'NEXT', compact: compact, onTap: next == null ? null : () => onSelect(selected + 1)))]),
      const SizedBox(height: 9), Row(children: [const Text('PREVIOUS  |  ', style: TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x45FFFFFF))), Expanded(child: Text(current.title.toUpperCase(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0xAFFFFFFF)))), const Text('  |  NEXT', style: TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x45FFFFFF))), const SizedBox(width: 10), Text('${selected + 1} / ${items.length}', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x55FFFFFF)))]),
    ]);
  }
}

class _Current extends StatelessWidget {
  final ContentItem item; final bool compact; final VoidCallback onOpen;
  const _Current({required this.item, required this.compact, required this.onOpen});
  @override Widget build(BuildContext context) {
    final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}'; final h = compact ? 270.0 : 360.0;
    return GestureDetector(onTap: onOpen, child: Container(height: h, decoration: BoxDecoration(color: const Color(0xD4080914), border: Border.all(color: const Color(0x657F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 32)]), child: Stack(children: [
      Positioned.fill(child: _CaseArtwork(url: url, title: item.title, emphasis: true)),
      Positioned(left: 18, right: 18, bottom: 16, child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('CURRENT / ARCHIVE CORE', style: TextStyle(fontSize: 7, letterSpacing: 2.4, color: Color(0x8897A8BE))), const SizedBox(height: 5), Text(item.title.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 16 : 23, letterSpacing: 2, fontWeight: FontWeight.w300, shadows: const [Shadow(blurRadius: 14, color: Colors.black)]))])), FilledButton(onPressed: onOpen, child: const Text('OPEN WORLD'))]))
    ])));
  }
}

class _Neighbor extends StatelessWidget {
  final ContentItem? item; final String label; final bool compact; final VoidCallback? onTap;
  const _Neighbor({required this.item, required this.label, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) {
    final url = item == null ? '' : '${item!.metadata['public_url'] ?? item!.metadata['image_url'] ?? ''}';
    return GestureDetector(onTap: onTap, child: Opacity(opacity: item == null ? .18 : .72, child: Container(height: compact ? 270 : 360, decoration: BoxDecoration(color: const Color(0x88070810), border: Border.all(color: const Color(0x267F70B0))), child: Stack(children: [Positioned.fill(child: _CaseArtwork(url: url, title: item?.title ?? '—', muted: true)), Positioned(left: 10, right: 10, bottom: 9, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 6, letterSpacing: 2, color: Color(0x6697A8BE))), const SizedBox(height: 4), Text(item?.title.toUpperCase() ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, letterSpacing: 1, color: Color(0xCCFFFFFF)))]))])));
  }
}

class _ArchiveGrid extends StatelessWidget {
  final List<ContentItem> items; final bool compact; final int selected; final ValueChanged<int> onSelect; final ValueChanged<ContentItem> onOpen;
  const _ArchiveGrid({required this.items, required this.compact, required this.selected, required this.onSelect, required this.onOpen});
  @override Widget build(BuildContext context) => GridView.builder(physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: items.length, gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: compact ? 170 : 220, mainAxisExtent: compact ? 255 : 300, crossAxisSpacing: 12, mainAxisSpacing: 12), itemBuilder: (_, i) {
    final item = items[i]; final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}'; final active = i == selected;
    return GestureDetector(onTap: () => onSelect(i), onDoubleTap: () => onOpen(item), child: AnimatedContainer(duration: const Duration(milliseconds: 220), decoration: BoxDecoration(color: const Color(0xCC080811), border: Border.all(color: active ? const Color(0xAA8A78B5) : const Color(0x1DFFFFFF)), boxShadow: active ? const [BoxShadow(color: Color(0x401F163B), blurRadius: 24)] : null), child: Stack(children: [Positioned.fill(child: _CaseArtwork(url: url, title: item.title, emphasis: active)), Positioned(left: 10, right: 10, bottom: 9, child: Container(padding: const EdgeInsets.all(7), color: const Color(0xAA05050A), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${(i + 1).toString().padLeft(3, '0')} / ARCHIVE', style: const TextStyle(fontSize: 5.5, letterSpacing: 1.6, color: Color(0x66FFFFFF))), const SizedBox(height: 4), Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, letterSpacing: .7, color: active ? Colors.white : const Color(0xCCFFFFFF)))]))) ])));
  });
}

class _CaseArtwork extends StatelessWidget {
  final String url; final String title; final bool muted; final bool emphasis;
  const _CaseArtwork({required this.url, required this.title, this.muted = false, this.emphasis = false});
  @override Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context); final width = math.min(media.width * (emphasis ? .34 : .19), emphasis ? 390.0 : 190.0); final height = width * 1.34;
    final image = url.isEmpty ? Container(width: width, height: height, alignment: Alignment.center, padding: const EdgeInsets.all(15), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF19172A), Color(0xFF050509)]), borderRadius: BorderRadius.circular(4)), child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: emphasis ? 13 : 8, letterSpacing: 1.2, color: muted ? const Color(0x66FFFFFF) : Colors.white))) : Image.network(url, width: width, height: height, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Center(child: Text(title, textAlign: TextAlign.center)));
    return Center(child: Transform.rotate(angle: emphasis ? -.012 : 0, child: Container(width: width + 12, height: height + 16, padding: const EdgeInsets.fromLTRB(5, 5, 9, 9), decoration: BoxDecoration(color: const Color(0xDD101019), border: Border.all(color: const Color(0x557F70B0)), borderRadius: BorderRadius.circular(3), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .78), blurRadius: emphasis ? 32 : 20, offset: const Offset(8, 12))]), child: Stack(children: [Positioned.fill(child: image), Positioned(right: 1, top: 3, bottom: 3, width: 4, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0x883F3F50), Color(0x11101018)])))), Positioned(top: 1, left: 8, right: 10, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: Color(0x557F70B0), borderRadius: BorderRadius.circular(2))))]))));
  }
}

class _SectionHeader extends StatelessWidget { final int count; final String query; const _SectionHeader({required this.count, required this.query}); @override Widget build(BuildContext context) => Row(children: [const Text('ARCHIVE / PHYSICAL MEDIA', style: TextStyle(fontSize: 9, letterSpacing: 3)), const SizedBox(width: 10), Text('$count ITEMS', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.7, color: Color(0x55FFFFFF))), if (query.isNotEmpty) ...[const SizedBox(width: 10), Flexible(child: Text('FILTER: $query', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.2, color: Color(0x668D7DB2)))] ]); }
class _EmptyArchive extends StatelessWidget { const _EmptyArchive(); @override Widget build(BuildContext context) => Center(child: Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: const Color(0xAA080812), border: Border.all(color: const Color(0x227F70B0))), child: const Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.inventory_2_outlined, size: 32, color: Color(0x557F70B0)), SizedBox(height: 15), Text('GEEN CONTENT', style: TextStyle(fontSize: 10, letterSpacing: 3, color: Color(0x99FFFFFF))), SizedBox(height: 7), Text('THIS WORLD IS READY FOR ITS ARCHIVE.', style: TextStyle(fontSize: 6.5, letterSpacing: 1.7, color: Color(0x44FFFFFF)))])); }
class _ArchivePainter extends CustomPainter { final double phase; const _ArchivePainter(this.phase); @override void paint(Canvas c, Size s) { c.drawRect(Offset.zero & s, Paint()..shader = const RadialGradient(center: Alignment(0, -.2), radius: 1.2, colors: [Color(0xFF211A35), Color(0xFF090911), Color(0xFF010106)]).createShader(Offset.zero & s)); final r = math.Random(71); for (var i = 0; i < 180; i++) { final x = r.nextDouble() * s.width, y = r.nextDouble() * s.height; c.drawCircle(Offset(x, y), .4 + r.nextDouble() * 1.1, Paint()..color = Colors.white.withValues(alpha: .08 + r.nextDouble() * .25)); } final scan = (phase * s.height * 1.5) % (s.height + 100) - 50; c.drawRect(Rect.fromLTWH(0, scan, s.width, 1), Paint()..color = const Color(0x147F70B0)); c.drawRect(Offset.zero & s, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x22000000), Color(0x88000000)]).createShader(Offset.zero & s)); } @override bool shouldRepaint(covariant _ArchivePainter old) => old.phase != phase; }

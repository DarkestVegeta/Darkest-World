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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 80))..repeat();
  bool loading = true;
  String query = '';
  int selected = 0;

  bool get snes => widget.contentType == 'game' && (widget.platformIds.contains(19) || widget.title.toUpperCase().contains('SNES'));

  @override void initState() { super.initState(); load(); }
  @override void dispose() { clock.dispose(); super.dispose(); }

  Future<void> load() async {
    try {
      List<ContentItem> result;
      if (snes) {
        final rows = await supabase.from('storage_assets').select('id,title,public_url,metadata').eq('asset_type','snes_sealed').not('public_url','is',null).neq('public_url','').order('title').limit(1000);
        result = [for (final row in rows) _snes(Map<String, dynamic>.from(row))];
      } else {
        result = await repository.getContentItemsPage(type: widget.contentType, page: 0);
      }
      if (mounted) setState(() { items.addAll(result); loading = false; });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  ContentItem _snes(Map<String, dynamic> row) {
    final meta = row['metadata'] is Map ? Map<String, dynamic>.from(row['metadata']) : <String, dynamic>{};
    meta['public_url'] = row['public_url'];
    return ContentItem.fromRow({'id': 'snes:${row['id']}', 'content_type': 'game', 'title': '${row['title'] ?? 'Untitled'}', 'slug': 'snes-${row['id']}', 'metadata': meta});
  }

  void open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  @override Widget build(BuildContext context) {
    final shown = items.where((x) => query.isEmpty || x.title.toLowerCase().contains(query.toLowerCase())).toList();
    if (selected >= shown.length) selected = shown.isEmpty ? 0 : shown.length - 1;
    final compact = MediaQuery.sizeOf(context).width < 850;
    return Scaffold(
      backgroundColor: const Color(0xFF010107),
      body: AnimatedBuilder(
        animation: clock,
        builder: (_, __) => Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _ArchivePainter(clock.value))),
          SafeArea(child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 14 : 30, compact ? 12 : 22, compact ? 14 : 30, 12),
            child: Column(children: [
              _TopBar(title: widget.title, compact: compact, onBack: () => Navigator.pop(context), onSearch: (v) => setState(() { query = v; selected = 0; })),
              const SizedBox(height: 18),
              Expanded(child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : shown.isEmpty
                      ? const _EmptyArchive()
                      : ListView(physics: const BouncingScrollPhysics(), children: [
                          _HeroArchive(items: shown, selected: selected, compact: compact, onSelect: (i) => setState(() => selected = i), onOpen: open),
                          const SizedBox(height: 22),
                          _SectionHeader(count: shown.length, query: query),
                          const SizedBox(height: 10),
                          _ArchiveGrid(items: shown, compact: compact, selected: selected, onSelect: (i) => setState(() => selected = i), onOpen: open),
                        ])),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title; final bool compact; final VoidCallback onBack; final ValueChanged<String> onSearch;
  const _TopBar({required this.title, required this.compact, required this.onBack, required this.onSearch});
  @override Widget build(BuildContext context) => Row(children: [
    IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new, size: 15, color: Color(0xBFFFFFFF))),
    const SizedBox(width: 5),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 2.8)),
      const SizedBox(height: 4),
      const Text('DARK CORE / CONTENT ARCHIVE', style: TextStyle(fontSize: 6.5, letterSpacing: 2, color: Color(0x55FFFFFF))),
    ])),
    SizedBox(width: compact ? 150 : 260, height: 34, child: TextField(
      onChanged: onSearch,
      style: const TextStyle(fontSize: 10, color: Colors.white),
      decoration: const InputDecoration(
        hintText: 'SEARCH ARCHIVE', hintStyle: TextStyle(fontSize: 8, color: Color(0x55FFFFFF)),
        prefixIcon: Icon(Icons.search, size: 14, color: Color(0x88FFFFFF)), filled: true, fillColor: Color(0x660A0B14),
        border: OutlineInputBorder(borderSide: BorderSide(color: Color(0x227F70B0))),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0x227F70B0))),
      ),
    )),
  ]);
}

class _HeroArchive extends StatelessWidget {
  final List<ContentItem> items; final int selected; final bool compact; final ValueChanged<int> onSelect; final ValueChanged<ContentItem> onOpen;
  const _HeroArchive({required this.items, required this.selected, required this.compact, required this.onSelect, required this.onOpen});
  @override Widget build(BuildContext context) {
    final current = items[selected];
    final previous = selected > 0 ? items[selected - 1] : null;
    final next = selected + 1 < items.length ? items[selected + 1] : null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _Neighbor(item: previous, label: 'PREVIOUS', compact: compact, onTap: previous == null ? null : () => onSelect(selected - 1))),
        const SizedBox(width: 10),
        Expanded(flex: 2, child: _Current(item: current, compact: compact, onOpen: () => onOpen(current))),
        const SizedBox(width: 10),
        Expanded(child: _Neighbor(item: next, label: 'NEXT', compact: compact, onTap: next == null ? null : () => onSelect(selected + 1))),
      ]),
      const SizedBox(height: 9),
      Row(children: [
        const Text('PREVIOUS  |  ', style: TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x45FFFFFF))),
        Expanded(child: Text(current.title.toUpperCase(), overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0xAFFFFFFF)))),
        const Text('  |  NEXT', style: TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x45FFFFFF))),
        const SizedBox(width: 10),
        Text('${selected + 1} / ${items.length}', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x55FFFFFF))),
      ]),
    ]);
  }
}

class _Current extends StatelessWidget {
  final ContentItem item; final bool compact; final VoidCallback onOpen;
  const _Current({required this.item, required this.compact, required this.onOpen});
  @override Widget build(BuildContext context) {
    final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}';
    final h = compact ? 250.0 : 330.0;
    return GestureDetector(onTap: onOpen, child: Container(
      height: h,
      decoration: BoxDecoration(color: const Color(0xCC080914), border: Border.all(color: const Color(0x657F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 30)]),
      child: Row(children: [
        Expanded(flex: 5, child: _Artwork(url: url, title: item.title)),
        Expanded(flex: 6, child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('CURRENT', style: TextStyle(fontSize: 7, letterSpacing: 3, color: Color(0x7897A8BE))),
          const SizedBox(height: 10),
          Text(item.title.toUpperCase(), maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 17 : 25, height: 1.05, letterSpacing: 2.5, fontWeight: FontWeight.w300)),
          const SizedBox(height: 13),
          const Text('DARK CORE ARCHIVE', style: TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0x66FFFFFF))),
          const SizedBox(height: 22),
          FilledButton(onPressed: onOpen, child: const Text('OPEN WORLD')),
        ]))),
      ]),
    ));
  }
}

class _Neighbor extends StatelessWidget {
  final ContentItem? item; final String label; final bool compact; final VoidCallback? onTap;
  const _Neighbor({required this.item, required this.label, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) {
    final url = item == null ? '' : '${item!.metadata['public_url'] ?? item!.metadata['image_url'] ?? ''}';
    return GestureDetector(onTap: onTap, child: Opacity(opacity: item == null ? .22 : .75, child: Container(
      height: compact ? 250 : 330,
      decoration: BoxDecoration(color: const Color(0x88070810), border: Border.all(color: const Color(0x267F70B0))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: _Artwork(url: url, title: item?.title ?? '—', muted: true)),
        Padding(padding: const EdgeInsets.fromLTRB(12, 9, 12, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 6, letterSpacing: 2, color: Color(0x5597A8BE))),
          const SizedBox(height: 5),
          Text(item?.title.toUpperCase() ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8.5, letterSpacing: 1.1, color: Color(0xBBFFFFFF))),
        ])),
      ]),
    )));
  }
}

class _ArchiveGrid extends StatelessWidget {
  final List<ContentItem> items; final bool compact; final int selected; final ValueChanged<int> onSelect; final ValueChanged<ContentItem> onOpen;
  const _ArchiveGrid({required this.items, required this.compact, required this.selected, required this.onSelect, required this.onOpen});
  @override Widget build(BuildContext context) => GridView.builder(
    physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: items.length,
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: compact ? 170 : 220, mainAxisExtent: compact ? 245 : 285, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemBuilder: (_, i) {
      final item = items[i]; final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}'; final active = i == selected;
      return GestureDetector(onTap: () => onSelect(i), onDoubleTap: () => onOpen(item), child: AnimatedContainer(duration: const Duration(milliseconds: 220), decoration: BoxDecoration(
        color: const Color(0xCC080811), border: Border.all(color: active ? const Color(0xAA8A78B5) : const Color(0x1DFFFFFF)), boxShadow: active ? const [BoxShadow(color: Color(0x401F163B), blurRadius: 22)] : null,
      ), child: Column(children: [
        Expanded(child: _Artwork(url: url, title: item.title)),
        Container(padding: const EdgeInsets.fromLTRB(10, 9, 10, 11), width: double.infinity, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${(i + 1).toString().padLeft(3, '0')}  /  ARCHIVE', style: const TextStyle(fontSize: 5.5, letterSpacing: 1.6, color: Color(0x4FFFFFFF))),
          const SizedBox(height: 5),
          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 9, letterSpacing: .7, color: active ? Colors.white : const Color(0xBBFFFFFF))),
        ])),
      ])));
    },
  );
}

class _Artwork extends StatelessWidget {
  final String url; final String title; final bool muted;
  const _Artwork({required this.url, required this.title, this.muted = false});
  @override Widget build(BuildContext context) {
    if (url.isEmpty) return Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF151426), Color(0xFF07070D)])), child: Center(child: Padding(padding: const EdgeInsets.all(15), child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, letterSpacing: 1.2, color: muted ? const Color(0x77FFFFFF) : Colors.white)))));
    return Image.network(url, fit: BoxFit.contain, width: double.infinity, errorBuilder: (_, __, ___) => Center(child: Text(title, textAlign: TextAlign.center)));
  }
}

class _SectionHeader extends StatelessWidget {
  final int count; final String query;
  const _SectionHeader({required this.count, required this.query});
  @override Widget build(BuildContext context) => Row(children: [
    const Text('ARCHIVE', style: TextStyle(fontSize: 9, letterSpacing: 3)), const SizedBox(width: 10),
    Text('$count ITEMS', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.7, color: Color(0x55FFFFFF))),
    if (query.isNotEmpty) ...[const SizedBox(width: 10), Flexible(child: Text('FILTER: $query', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.2, color: Color(0x668D7DB2))))],
  ]);
}

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();
  @override Widget build(BuildContext context) => Center(child: Container(padding: const EdgeInsets.all(40), decoration: BoxDecoration(color: const Color(0xAA080812), border: Border.all(color: const Color(0x227F70B0))), child: const Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.inventory_2_outlined, size: 32, color: Color(0x557F70B0)), SizedBox(height: 15), Text('GEEN CONTENT', style: TextStyle(fontSize: 10, letterSpacing: 3, color: Color(0x99FFFFFF))), SizedBox(height: 7), Text('THIS WORLD IS READY FOR ITS ARCHIVE.', style: TextStyle(fontSize: 6.5, letterSpacing: 1.7, color: Color(0x44FFFFFF))),
  ])));
}

class _ArchivePainter extends CustomPainter {
  final double phase; const _ArchivePainter(this.phase);
  @override void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..shader = const RadialGradient(center: Alignment(0, -.2), radius: 1.2, colors: [Color(0xFF211A35), Color(0xFF090911), Color(0xFF010106)]).createShader(Offset.zero & s));
    final r = math.Random(71);
    for (var i = 0; i < 180; i++) {
      final x = r.nextDouble() * s.width, y = r.nextDouble() * s.height;
      c.drawCircle(Offset(x, y), .4 + r.nextDouble() * 1.1, Paint()..color = Colors.white.withValues(alpha: .08 + r.nextDouble() * .25));
    }
    final scan = (phase * s.height * 1.5) % (s.height + 100) - 50;
    c.drawRect(Rect.fromLTWH(0, scan, s.width, 1), Paint()..color = const Color(0x147F70B0));
    c.drawRect(Offset.zero & s, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x22000000), Color(0x88000000)]).createShader(Offset.zero & s));
  }
  @override bool shouldRepaint(covariant _ArchivePainter old) => old.phase != phase;
}

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
  final navigation = GalaxyNavigationSession.instance;
  final items = <ContentItem>[];
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 90))..repeat();
  String query = '';
  int selected = 0;
  bool loading = true;

  bool get isSnes => widget.contentType == 'game' && (widget.platformIds.contains(19) || widget.title.toUpperCase().contains('SNES'));
  List<ContentItem> get shown => items.where((item) => query.isEmpty || item.title.toLowerCase().contains(query.toLowerCase())).toList();

  @override void initState() { super.initState(); _load(); }
  @override void dispose() { clock.dispose(); super.dispose(); }

  void _publish() {
    final list = shown;
    if (list.isEmpty) { navigation.clearContentNavigation(); return; }
    selected = selected.clamp(0, list.length - 1);
    navigation.publishContentNavigation(DarkestWorldNavigationState(
      previous: selected > 0 ? list[selected - 1] : null,
      current: list[selected],
      next: selected + 1 < list.length ? list[selected + 1] : null,
      related: const [],
      source: 'archive',
    ));
  }

  Future<void> _load() async {
    try {
      List<ContentItem> result;
      if (isSnes) {
        final rows = await supabase.from('storage_assets').select('id,title,public_url,metadata').eq('asset_type', 'snes_sealed').not('public_url', 'is', null).neq('public_url', '').order('title').limit(1000);
        result = [for (final row in rows) _asset(Map<String, dynamic>.from(row))];
      } else {
        result = await repository.getContentItemsPage(type: widget.contentType, page: 0);
      }
      if (!mounted) return;
      setState(() { items.addAll(result); loading = false; });
      _publish();
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  ContentItem _asset(Map<String, dynamic> row) {
    final meta = row['metadata'] is Map ? Map<String, dynamic>.from(row['metadata']) : <String, dynamic>{};
    meta['public_url'] = row['public_url'];
    return ContentItem.fromRow({'id': 'snes:${row['id']}', 'content_type': 'game', 'title': '${row['title'] ?? 'Untitled'}', 'slug': 'snes-${row['id']}', 'metadata': meta});
  }

  void _select(int index) { if (shown.isEmpty) return; setState(() => selected = index.clamp(0, shown.length - 1)); _publish(); }
  void _open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));
  KeyEventResult _keys(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent || shown.isEmpty) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) { _select(selected - 1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) { _select(selected + 1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.enter) { _open(shown[selected]); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }

  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    final list = shown;
    if (list.isNotEmpty) selected = selected.clamp(0, list.length - 1);
    return Focus(autofocus: true, onKeyEvent: _keys, child: Scaffold(
      backgroundColor: const Color(0xFF010208),
      body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _ArchiveSpace(clock.value))),
        SafeArea(child: Padding(padding: EdgeInsets.all(compact ? 12 : 28), child: Column(children: [
          Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 14)),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 2.8)), const Text('DARK CORE / PHYSICAL MEDIA ARCHIVE', style: TextStyle(fontSize: 6.5, letterSpacing: 2, color: Color(0x55FFFFFF)))])),
            SizedBox(width: compact ? 150 : 260, height: 34, child: TextField(onChanged: (value) { query = value; selected = 0; setState(() {}); _publish(); }, style: const TextStyle(fontSize: 10), decoration: const InputDecoration(hintText: 'SEARCH ARCHIVE', prefixIcon: Icon(Icons.search, size: 14), filled: true, fillColor: Color(0x660A0B14))))
          ]),
          const SizedBox(height: 16),
          Expanded(child: loading ? const Center(child: CircularProgressIndicator()) : list.isEmpty ? const Center(child: Text('ARCHIVE EMPTY', style: TextStyle(letterSpacing: 3))) : ListView(children: [
            _Hero(items: list, selected: selected, compact: compact, onSelect: _select, onOpen: _open),
            const SizedBox(height: 24),
            Text('${list.length} ARCHIVE ASSETS', style: const TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0x6697A8BE))),
            const SizedBox(height: 10),
            _Grid(items: list, selected: selected, compact: compact, onSelect: _select, onOpen: _open),
          ])),
        ])))
      ])),
    ));
  }
}

class _Hero extends StatelessWidget {
  final List<ContentItem> items; final int selected; final bool compact; final ValueChanged<int> onSelect; final ValueChanged<ContentItem> onOpen;
  const _Hero({required this.items, required this.selected, required this.compact, required this.onSelect, required this.onOpen});
  @override Widget build(BuildContext context) {
    final current = items[selected];
    final previous = selected > 0 ? items[selected - 1] : null;
    final next = selected + 1 < items.length ? items[selected + 1] : null;
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Expanded(child: _Case(item: previous, label: 'PREVIOUS', height: compact ? 250 : 340, onTap: previous == null ? null : () => onSelect(selected - 1))),
      const SizedBox(width: 10),
      Expanded(flex: 2, child: _Case(item: current, label: 'CURRENT / ARCHIVE CORE', height: compact ? 280 : 380, emphasis: true, onTap: () => onOpen(current))),
      const SizedBox(width: 10),
      Expanded(child: _Case(item: next, label: 'NEXT', height: compact ? 250 : 340, onTap: next == null ? null : () => onSelect(selected + 1))),
    ]);
  }
}

class _Grid extends StatelessWidget {
  final List<ContentItem> items; final int selected; final bool compact; final ValueChanged<int> onSelect; final ValueChanged<ContentItem> onOpen;
  const _Grid({required this.items, required this.selected, required this.compact, required this.onSelect, required this.onOpen});
  @override Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length,
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: compact ? 170 : 220, mainAxisExtent: compact ? 240 : 285, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemBuilder: (_, index) => GestureDetector(onTap: () => onSelect(index), onDoubleTap: () => onOpen(items[index]), child: _Case(item: items[index], label: '${(index + 1).toString().padLeft(3, '0')} / ARCHIVE', height: compact ? 240 : 285, emphasis: index == selected, onTap: () => onSelect(index))),
  );
}

class _Case extends StatelessWidget {
  final ContentItem? item; final String label; final double height; final bool emphasis; final VoidCallback? onTap;
  const _Case({required this.item, required this.label, required this.height, this.emphasis = false, required this.onTap});
  @override Widget build(BuildContext context) {
    final url = item == null ? '' : '${item!.metadata['public_url'] ?? item!.metadata['image_url'] ?? ''}';
    return GestureDetector(onTap: onTap, child: Container(height: height, decoration: BoxDecoration(color: const Color(0xD4080914), border: Border.all(color: emphasis ? const Color(0x887F70B0) : const Color(0x267F70B0)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: emphasis ? 34 : 20, offset: const Offset(8, 12))]), child: Stack(children: [
      Center(child: _Artwork(url: url, title: item?.title ?? '—', emphasis: emphasis)),
      Positioned(left: 10, right: 10, bottom: 10, child: Container(padding: const EdgeInsets.all(8), color: const Color(0xAA05050A), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 6, letterSpacing: 1.8, color: Color(0x7797A8BE))), const SizedBox(height: 4), Text(item?.title.toUpperCase() ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: emphasis ? 11 : 8, letterSpacing: 1.1))])))
    ]));
  }
}

class _Artwork extends StatelessWidget {
  final String url; final String title; final bool emphasis;
  const _Artwork({required this.url, required this.title, required this.emphasis});
  @override Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width * (emphasis ? .31 : .17), emphasis ? 360.0 : 175.0);
    final height = width * 1.34;
    final child = url.isEmpty ? Container(alignment: Alignment.center, padding: const EdgeInsets.all(12), decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A1830), Color(0xFF05050A)])), child: Text(title, textAlign: TextAlign.center)) : Image.network(url, width: width, height: height, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Text(title, textAlign: TextAlign.center));
    return Container(width: width + 14, height: height + 18, padding: const EdgeInsets.fromLTRB(5, 5, 9, 9), decoration: BoxDecoration(color: const Color(0xDD101019), border: Border.all(color: const Color(0x557F70B0)), borderRadius: BorderRadius.circular(3)), child: Stack(children: [Positioned.fill(child: child), Positioned(right: 1, top: 3, bottom: 3, width: 4, child: DecoratedBox(decoration: BoxDecoration(color: const Color(0x553F3F50)))), Positioned(top: 1, left: 8, right: 10, height: 2, child: DecoratedBox(decoration: BoxDecoration(color: const Color(0x557F70B0))))]));
  }
}

class _ArchiveSpace extends CustomPainter {
  final double phase; const _ArchiveSpace(this.phase);
  @override void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(colors: [Color(0xFF14172A), Color(0xFF03050C), Color(0xFF010207)]).createShader(rect));
    final random = math.Random(71);
    for (var i = 0; i < 220; i++) { final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height); canvas.drawCircle(p, .25 + random.nextDouble() * .8, Paint()..color = Colors.white.withValues(alpha: .025 + .08 * ((math.sin(phase * math.pi * 2 + i) + 1) / 2))); }
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .5, size.height * .55), width: size.width * .86, height: size.height * .52), Paint()..style = PaintingStyle.stroke..strokeWidth = .6..color = const Color(0x1D8296A8));
  }
  @override bool shouldRepaint(covariant _ArchiveSpace old) => old.phase != phase;
}

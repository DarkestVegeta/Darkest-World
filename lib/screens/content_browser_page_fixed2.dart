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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 80))..repeat();
  bool loading = true;
  String query = '';
  int selected = 0;
  bool get snes => widget.contentType == 'game' && (widget.platformIds.contains(19) || widget.title.toUpperCase().contains('SNES'));
  List<ContentItem> get visible => items.where((x) => query.isEmpty || x.title.toLowerCase().contains(query.toLowerCase())).toList();
  @override void initState() { super.initState(); _load(); }
  @override void dispose() { clock.dispose(); super.dispose(); }
  void _publish() {
    if (visible.isEmpty) { navigation.clearContentNavigation(); return; }
    selected = selected.clamp(0, visible.length - 1);
    navigation.publishContentNavigation(DarkestWorldNavigationState(
      previous: selected > 0 ? visible[selected - 1] : null,
      current: visible[selected],
      next: selected + 1 < visible.length ? visible[selected + 1] : null,
      related: const [],
      source: 'archive',
    ));
  }
  void _select(int value) {
    if (visible.isEmpty) return;
    setState(() => selected = value.clamp(0, visible.length - 1));
    _publish();
  }
  void _open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));
  KeyEventResult _key(FocusNode _, KeyEvent event) {
    if (event is! KeyDownEvent || visible.isEmpty) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) { _select(selected - 1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) { _select(selected + 1); return KeyEventResult.handled; }
    if (event.logicalKey == LogicalKeyboardKey.enter) { _open(visible[selected]); return KeyEventResult.handled; }
    return KeyEventResult.ignored;
  }
  Future<void> _load() async {
    try {
      List<ContentItem> result;
      if (snes) {
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
      navigation.clearContentNavigation();
    }
  }
  ContentItem _asset(Map<String, dynamic> row) {
    final metadata = row['metadata'] is Map ? Map<String, dynamic>.from(row['metadata']) : <String, dynamic>{};
    metadata['public_url'] = row['public_url'];
    return ContentItem.fromRow({'id': 'snes:${row['id']}', 'content_type': 'game', 'title': '${row['title'] ?? 'Untitled'}', 'slug': 'snes-${row['id']}', 'metadata': metadata});
  }
  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    return Focus(
      autofocus: true,
      onKeyEvent: _key,
      child: Scaffold(
        backgroundColor: const Color(0xFF010107),
        body: AnimatedBuilder(
          animation: clock,
          builder: (_, __) => Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _ArchivePainter(clock.value))),
            SafeArea(child: Padding(
              padding: EdgeInsets.all(compact ? 12 : 28),
              child: Column(children: [
                Row(children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 15)),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(widget.title.toUpperCase(), style: const TextStyle(fontSize: 12, letterSpacing: 2.8)),
                    const SizedBox(height: 4),
                    const Text('DARK CORE / PHYSICAL MEDIA ARCHIVE', style: TextStyle(fontSize: 6.5, letterSpacing: 2, color: Color(0x55FFFFFF))),
                  ])),
                  SizedBox(width: compact ? 150 : 260, height: 34, child: TextField(
                    onChanged: (value) { setState(() { query = value; selected = 0; }); _publish(); },
                    style: const TextStyle(fontSize: 10),
                    decoration: const InputDecoration(hintText: 'SEARCH ARCHIVE', prefixIcon: Icon(Icons.search, size: 14), filled: true, fillColor: Color(0x660A0B14)),
                  )),
                ]),
                const SizedBox(height: 16),
                Expanded(child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : visible.isEmpty
                        ? const Center(child: Text('GEEN CONTENT', style: TextStyle(letterSpacing: 3)))
                        : ListView(children: [
                            _Hero(items: visible, selected: selected, compact: compact, onSelect: _select, onOpen: _open),
                            const SizedBox(height: 24),
                            Text('${visible.length} ARCHIVE ASSETS', style: const TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0x6697A8BE))),
                            const SizedBox(height: 10),
                            _Grid(items: visible, selected: selected, onSelect: _select, onOpen: _open),
                          ])),
              ]),
            )),
          ]),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final List<ContentItem> items; final int selected; final bool compact; final ValueChanged<int> onSelect; final ValueChanged<ContentItem> onOpen;
  const _Hero({required this.items, required this.selected, required this.compact, required this.onSelect, required this.onOpen});
  @override Widget build(BuildContext context) {
    final current = items[selected];
    final previous = selected > 0 ? items[selected - 1] : null;
    final next = selected + 1 < items.length ? items[selected + 1] : null;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _Neighbor(item: previous, label: 'PREVIOUS', compact: compact, onTap: previous == null ? null : () => onSelect(selected - 1))),
      const SizedBox(width: 10),
      Expanded(flex: 2, child: _Current(item: current, compact: compact, onOpen: () => onOpen(current))),
      const SizedBox(width: 10),
      Expanded(child: _Neighbor(item: next, label: 'NEXT', compact: compact, onTap: next == null ? null : () => onSelect(selected + 1))),
    ]);
  }
}
class _Current extends StatelessWidget {
  final ContentItem item; final bool compact; final VoidCallback onOpen;
  const _Current({required this.item, required this.compact, required this.onOpen});
  @override Widget build(BuildContext context) {
    final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}';
    return GestureDetector(onTap: onOpen, child: Container(
      height: compact ? 280 : 390,
      decoration: BoxDecoration(color: const Color(0xD4080914), border: Border.all(color: const Color(0x657F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 32)]),
      child: Stack(children: [
        Positioned.fill(child: _Artwork(url: url, title: item.title, large: true)),
        Positioned(left: 14, right: 14, bottom: 14, child: Container(
          padding: const EdgeInsets.all(9), color: const Color(0xAA05050A),
          child: Row(children: [Expanded(child: Text(item.title.toUpperCase(), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 14 : 20, letterSpacing: 1.8))), FilledButton(onPressed: onOpen, child: const Text('OPEN WORLD'))]),
        )),
      ]),
    ));
  }
}
class _Neighbor extends StatelessWidget {
  final ContentItem? item; final String label; final bool compact; final VoidCallback? onTap;
  const _Neighbor({required this.item, required this.label, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) {
    final url = item == null ? '' : '${item!.metadata['public_url'] ?? item!.metadata['image_url'] ?? ''}';
    return GestureDetector(onTap: onTap, child: Opacity(opacity: item == null ? .18 : .72, child: Container(
      height: compact ? 280 : 390,
      decoration: BoxDecoration(color: const Color(0x88070810), border: Border.all(color: const Color(0x267F70B0))),
      child: Stack(children: [
        Positioned.fill(child: _Artwork(url: url, title: item?.title ?? '—')),
        Positioned(left: 10, right: 10, bottom: 10, child: Text('$label / ${item?.title ?? '—'}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 7, letterSpacing: 1.2))),
      ]),
    )));
  }
}
class _Grid extends StatelessWidget {
  final List<ContentItem> items; final int selected; final ValueChanged<int> onSelect; final ValueChanged<ContentItem> onOpen;
  const _Grid({required this.items, required this.selected, required this.onSelect, required this.onOpen});
  @override Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 220, mainAxisExtent: 290, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemBuilder: (_, i) {
      final item = items[i];
      final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}';
      final active = i == selected;
      return GestureDetector(onTap: () => onSelect(i), onDoubleTap: () => onOpen(item), child: Container(
        decoration: BoxDecoration(color: const Color(0xCC080811), border: Border.all(color: active ? const Color(0xAA8A78B5) : const Color(0x1DFFFFFF)), boxShadow: active ? const [BoxShadow(color: Color(0x401F163B), blurRadius: 24)] : null),
        child: Stack(children: [Center(child: _Artwork(url: url, title: item.title, large: active)), Positioned(left: 8, right: 8, bottom: 8, child: Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 8)))]),
      ));
    },
  );
}
class _Artwork extends StatelessWidget {
  final String url; final String title; final bool large;
  const _Artwork({required this.url, required this.title, this.large = false});
  @override Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width * (large ? .32 : .18), large ? 390.0 : 180.0);
    final height = width * 1.34;
    final image = url.isEmpty ? Center(child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: large ? 13 : 8))) : Image.network(url, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Center(child: Text(title, textAlign: TextAlign.center)));
    return Center(child: Container(width: width + 14, height: height + 18, padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: const Color(0xDD101019), border: Border.all(color: const Color(0x557F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 22, offset: Offset(8, 12))]), child: image));
  }
}
class _ArchivePainter extends CustomPainter { final double phase; const _ArchivePainter(this.phase); @override void paint(Canvas c, Size s) { final rect = Offset.zero & s; c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.2), radius: 1.2, colors: [Color(0xFF211A35), Color(0xFF090911), Color(0xFF010106)]).createShader(rect)); final r = math.Random(71); for (var i = 0; i < 180; i++) { final p = Offset(r.nextDouble() * s.width, r.nextDouble() * s.height); c.drawCircle(p, .4 + r.nextDouble() * 1.1, Paint()..color = Colors.white.withValues(alpha: .08 + r.nextDouble() * .25)); } final scan = (phase * s.height * 1.5) % (s.height + 100) - 50; c.drawRect(Rect.fromLTWH(0, scan, s.width, 1), Paint()..color = const Color(0x147F70B0)); } @override bool shouldRepaint(covariant _ArchivePainter old) => old.phase != phase; }

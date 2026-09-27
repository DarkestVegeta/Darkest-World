import 'dart:math' as math;
import 'package:flutter/material.dart';
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
  bool loading = true;
  String query = '';
  int selected = 0;
  int? hovered;
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 80))..repeat();

  bool get snes => widget.contentType == 'game' && (widget.platformIds.contains(19) || widget.title.toUpperCase().contains('SNES'));
  List<ContentItem> get visible => items.where((item) => item.title.toLowerCase().contains(query.toLowerCase())).toList(growable: false);

  @override
  void dispose() {
    _focusNode.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
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
      setState(() {
        items
          ..clear()
          ..addAll(result);
        loading = false;
        selected = 0;
      });
      _publish();
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  ContentItem _asset(Map<String, dynamic> row) {
    final metadata = row['metadata'] is Map ? Map<String, dynamic>.from(row['metadata']) : <String, dynamic>{};
    metadata['public_url'] = row['public_url'];
    return ContentItem.fromRow({
      'id': 'snes:${row['id']}',
      'content_type': 'game',
      'title': '${row['title'] ?? 'Untitled'}',
      'slug': 'snes-${row['id']}',
      'metadata': metadata,
    });
  }

  void _publish() {
    final list = visible;
    if (list.isEmpty) {
      navigation.clearContentNavigation();
      return;
    }
    selected = selected.clamp(0, list.length - 1);
    navigation.publishContentNavigation(DarkestWorldNavigationState(
      previous: selected > 0 ? list[selected - 1] : null,
      current: list[selected],
      next: selected + 1 < list.length ? list[selected + 1] : null,
      related: const [],
      source: 'archive',
      entryPoint: 'archive_browser',
    ));
  }

  void _select(int index) {
    if (visible.isEmpty) return;
    setState(() { selected = index.clamp(0, visible.length - 1); hovered = null; });
    _publish();
  }

  void _open(ContentItem item) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    final list = visible;
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: CustomPaint(painter: _ArchiveBrowserSpaceStatic())),
          IgnorePointer(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _clock,
                builder: (_, __) => CustomPaint(painter: _ArchiveBrowserAtmosphere(_clock.value)),
              ),
            ),
          ),
          Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (_, event) {
          if (event is! KeyDownEvent || list.isEmpty) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            _select(math.max(0, selected - 1));
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            _select(math.min(list.length - 1, selected + 1));
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.home) {
            _select(0);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.end) {
            _select(list.length - 1);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            _open(list[selected.clamp(0, list.length - 1).toInt()]);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 28),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 15)),
                  Expanded(child: Text(widget.title.toUpperCase(), style: const TextStyle(fontSize: 13, letterSpacing: 2.4))),
                  SizedBox(
                    width: compact ? 150 : 280,
                    height: 36,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          query = value;
                          selected = 0;
                        });
                        _publish();
                      },
                      decoration: const InputDecoration(hintText: 'SEARCH ARCHIVE', prefixIcon: Icon(Icons.search, size: 15), filled: true, fillColor: Color(0x660A0B14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : list.isEmpty
                        ? const Center(child: Text('GEEN CONTENT', style: TextStyle(letterSpacing: 3)))
                        : LayoutBuilder(
                            builder: (context, box) {
                              final center = selected.clamp(0, list.length - 1).toInt();
                              final start = (center - 2).clamp(0, math.max(0, list.length - 5)).toInt();
                              final end = math.min(list.length, start + 5).toInt();
                              final visibleItems = list.sublist(start, end);
                              return Column(
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        for (var slot = 0; slot < visibleItems.length; slot++)
                                          Expanded(
                                            flex: slot == center - start ? 12 : 10,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 6, vertical: 8),
                                              child: _ArchiveCard(
                                                item: visibleItems[slot],
                                                active: slot == center - start,
                                                hovered: hovered == start + slot,
                                                onHover: (v) => setState(() => hovered = v ? start + slot : null),
                                                onTap: () => _select(start + slot),
                                                onDoubleTap: () => _open(visibleItems[slot]),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('PREVIOUS', style: TextStyle(fontSize: 7, letterSpacing: 2, color: Colors.white.withValues(alpha: .30))),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 18),
                                        child: Text(
                                          visibleItems.isEmpty ? '' : visibleItems[center - start].title.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 8, letterSpacing: 2.2),
                                        ),
                                      ),
                                      Text('NEXT', style: TextStyle(fontSize: 7, letterSpacing: 2, color: Colors.white.withValues(alpha: .30))),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
          ),
          ),
        ],
      ),
    );
  }
}


class _ArchiveBrowserSpaceStatic extends CustomPainter {
  const _ArchiveBrowserSpaceStatic();

  @override
  void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(
      center: Alignment(0, -.18),
      radius: 1.08,
      colors: [Color(0xFF11172A), Color(0xFF060912), Color(0xFF010207)],
    ).createShader(rect));
    final bloom = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x3A765EA8),
          const Color(0x001E2440),
        ],
      ).createShader(Rect.fromCircle(center: Offset(s.width * .50, s.height * .42), radius: s.shortestSide * .72));
    c.drawCircle(Offset(s.width * .50, s.height * .42), s.shortestSide * .72, bloom);
  }

  @override
  bool shouldRepaint(covariant _ArchiveBrowserSpaceStatic oldDelegate) => false;
}

class _ArchiveBrowserAtmosphere extends CustomPainter {
  final double phase;
  const _ArchiveBrowserAtmosphere(this.phase);

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .47);
    final r = math.min(s.width, s.height) * .34;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, r * .009)
      ..color = const Color(0x247F6FB4);
    c.drawArc(Rect.fromCircle(center: center, radius: r * 1.18), phase * math.pi * 2, .75, false, arc);
    c.drawArc(Rect.fromCircle(center: center, radius: r * 1.36), phase * math.pi * -1.3 + 2.2, .42, false, arc..color = const Color(0x1D9AB2C5));
    final mist = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [Color(0x000A0C18), Color(0x267A5BA5), Color(0x000A0C18)],
      ).createShader(Rect.fromLTWH(0, s.height * .25, s.width, s.height * .55));
    c.drawRect(Rect.fromLTWH(0, s.height * .25, s.width, s.height * .55), mist);
  }

  @override
  bool shouldRepaint(covariant _ArchiveBrowserAtmosphere oldDelegate) => oldDelegate.phase != phase;
}

class _ArchiveCard extends StatelessWidget {
  final ContentItem item;
  final bool active;
  final bool hovered;
  final ValueChanged<bool> onHover;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const _ArchiveCard({
    required this.item,
    required this.active,
    required this.hovered,
    required this.onHover,
    required this.onTap,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = '${item.metadata['public_url'] ?? item.metadata['image_url'] ?? ''}';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        child: AnimatedScale(
          scale: active ? 1.015 : (hovered ? 1.0 : .94),
          duration: const Duration(milliseconds: 220),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: active ? const Color(0xD90B0A16) : (hovered ? const Color(0xA40A0A15) : const Color(0x86070810)),
              border: Border.all(
                color: active ? const Color(0x8F8A78B5) : (hovered ? const Color(0x557F70B0) : const Color(0x1F7F70B0)),
                width: active ? 1.2 : 1,
              ),
              boxShadow: active
                  ? const [BoxShadow(color: Color(0x22000000), blurRadius: 24, spreadRadius: 2)]
                  : const [],
            ),
            child: Column(
              children: [
                Expanded(
                  child: url.isEmpty
                      ? Center(
                          child: Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: active ? 12 : 9, letterSpacing: 1.2),
                          ),
                        )
                      : Image.network(
                          url,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          errorBuilder: (_, __, ___) => Center(
                            child: Text(item.title, textAlign: TextAlign.center),
                          ),
                        ),
                ),
                const SizedBox(height: 9),
                Text(
                  item.title.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: active ? 9 : 7,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

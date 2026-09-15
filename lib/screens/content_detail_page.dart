import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/chat_scope.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
import '../core/darkest_world_navigation_state.dart';
import '../widgets/archive_signal_telemetry_lens.dart';
import '../widgets/darkest_world_artbox.dart';
import 'chatbox.dart';

class ContentDetailPage extends StatefulWidget {
  final ContentItem item;
  const ContentDetailPage({super.key, required this.item});
  @override State<ContentDetailPage> createState() => _ContentDetailPageState();
}

class _ContentDetailPageState extends State<ContentDetailPage> with SingleTickerProviderStateMixin {
  final _repository = ContentRepository();
  late final AnimationController _clock = AnimationController(vsync: this, duration: const Duration(seconds: 70))..repeat();
  List<ContentItem> _related = const [];
  TypedFranchiseNavigation? _navigation;
  bool _relatedLoading = true;
  bool _navigationLoading = true;
  String? _relatedError;
  String? _navigationError;

  String get _title => widget.item.title;
  String get _type => widget.item.type.name;
  String get _franchise => widget.item.franchise ?? '';
  String get _description => widget.item.description ?? '';
  bool get _isExternal => widget.item.externalSource != null && widget.item.externalId != null;

  DarkestWorldNavigationState? get _archiveNavigationState {
    final navigation = _navigation;
    if (navigation == null) return null;
    return DarkestWorldNavigationState(
      previous: navigation.previous,
      current: widget.item,
      next: navigation.next,
      related: _related,
      source: 'content_detail',
      entryPoint: 'detail',
    );
  }

  String? get _artUrl {
    for (final key in ['transparent_artbox_url', 'artbox_url', 'public_url', 'image_url', 'artwork_url', 'cover_url']) {
      final value = widget.item.metadata[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Map<String, String> get _intel {
    final source = widget.item.metadata;
    final result = <String, String>{};
    void add(String label, List<String> keys) {
      for (final key in keys) {
        final value = source[key];
        if (value != null && '$value'.trim().isNotEmpty) {
          result[label] = '$value'.trim();
          return;
        }
      }
    }
    add('PLATFORM', ['platform', 'platform_name', 'console']);
    add('REGION', ['region', 'regions']);
    add('LANGUAGE', ['language', 'languages']);
    add('DEVELOPER', ['developer', 'developers']);
    add('PUBLISHER', ['publisher', 'publishers']);
    add('GENRE', ['genre', 'genres']);
    add('PLAYTIME', ['playtime', 'estimated_playtime']);
    add('RATING', ['rating', 'age_rating']);
    return result;
  }

  String? get _longplayUrl {
    for (final key in ['longplay_url', 'longplay', 'youtube_url', 'youtube']) {
      final value = widget.item.metadata[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  @override void initState() {
    super.initState();
    if (_isExternal) {
      _relatedLoading = false;
      _navigationLoading = false;
    } else {
      _loadRelated();
      _loadNavigation();
    }
  }
  @override void dispose() { _clock.dispose(); super.dispose(); }

  Future<void> _loadRelated() async {
    try {
      final result = await _repository.getRelatedContentItems(widget.item.id);
      if (!mounted) return;
      setState(() { _related = result; _relatedLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _relatedLoading = false; _relatedError = e.toString(); });
    }
  }

  Future<void> _loadNavigation() async {
    try {
      final result = await _repository.getTypedFranchiseNavigation(widget.item);
      if (!mounted) return;
      setState(() { _navigation = result; _navigationLoading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _navigationLoading = false; _navigationError = e.toString(); });
    }
  }

  ChatContext? get _chatContext {
    if (_isExternal) return null;
    ChatScope? scope;
    if (_type == 'game') scope = ChatScope.games;
    if (_type == 'movie') scope = ChatScope.movies;
    if (_type == 'series') scope = ChatScope.series;
    if (scope == null) return null;
    return ChatContext(scope: scope, contentId: widget.item.id, contentTitle: _title);
  }

  void _open(ContentItem item) => Navigator.push(context, MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));
  void _copyValue(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ARCHIVE VALUE COPIED')));
  }

  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    final archiveNavigationState = _archiveNavigationState;
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (_, __) => Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _DetailSpacePainter(_clock.value))),
          SafeArea(child: ListView(padding: EdgeInsets.fromLTRB(compact ? 14 : 42, 14, compact ? 14 : 42, 55), children: [
            _Header(title: _title, onBack: () => Navigator.pop(context)),
            const SizedBox(height: 22),
            _GameWorldHero(item: widget.item, artUrl: _artUrl, compact: compact, phase: _clock.value),
            const SizedBox(height: 22),
            _MetaStrip(item: widget.item, type: _type, franchise: _franchise),
            if (_description.isNotEmpty) ...[const SizedBox(height: 22), _Description(text: _description)],
            const SizedBox(height: 28),
            _SectionTitle(label: 'ARTBOX SYSTEM', detail: 'TRANSPARENT 3D ARCHIVE OBJECT'),
            const SizedBox(height: 11),
            _ArtboxInfo(compact: compact, hasArt: _artUrl != null),
            if (_intel.isNotEmpty) ...[
              const SizedBox(height: 28),
              _SectionTitle(label: 'ARCHIVE INTEL', detail: 'STRUCTURED WORLD DATA'),
              const SizedBox(height: 11),
              _IntelGrid(values: _intel, compact: compact),
            ],
            const SizedBox(height: 28),
            _SectionTitle(label: 'MEDIA CHAMBER', detail: 'LONGPLAY / REFERENCE SIGNAL'),
            const SizedBox(height: 11),
            _MediaChamber(url: _longplayUrl, compact: compact, copy: _copyValue),
            if (archiveNavigationState != null) ...[
              const SizedBox(height: 28),
              _SectionTitle(label: 'ARCHIVE SIGNAL', detail: 'LIVE NAVIGATION TELEMETRY'),
              const SizedBox(height: 11),
              ArchiveSignalTelemetryLens(
                state: archiveNavigationState,
                phase: _clock.value,
                compact: compact,
                onRelatedTap: _open,
              ),
            ],
            const SizedBox(height: 28),
            _SectionTitle(label: 'NAVIGATION', detail: 'PREVIOUS  |  CURRENT  |  NEXT'),
            const SizedBox(height: 11),
            if (_navigationLoading) const _LoadingPanel()
            else if (_navigationError != null) const _MessagePanel(text: 'FRANCHISE NAVIGATION UNAVAILABLE')
            else if (_navigation == null) const _MessagePanel(text: 'NO FRANCHISE ORDER AVAILABLE')
            else _NavigationRow(navigation: _navigation!, compact: compact, open: _open),
            const SizedBox(height: 28),
            _SectionTitle(label: 'RELATED', detail: 'CONNECTED WORLDS'),
            const SizedBox(height: 11),
            if (_relatedLoading) const _LoadingPanel()
            else if (_relatedError != null) const _MessagePanel(text: 'RELATED CONTENT UNAVAILABLE')
            else if (_related.isEmpty) const _MessagePanel(text: 'NO RELATED WORLDS YET')
            else _RelatedGrid(items: _related, compact: compact, open: _open),
            if (_isExternal) ...[const SizedBox(height: 24), const _MessagePanel(text: 'LIVE EXTERNAL RESULT — NOT STORED IN THE DARKESTWORLD DATABASE')],
          ])),
        ]),
      ),
      floatingActionButton: _chatContext == null ? null : Chatbox(contextData: _chatContext!),
    );
  }
}

class _Header extends StatelessWidget {
  final String title; final VoidCallback onBack;
  const _Header({required this.title, required this.onBack});
  @override Widget build(BuildContext context) => Row(children: [
    IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new, size: 15, color: Color(0xBBFFFFFF))),
    const SizedBox(width: 7),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('DARKESTWORLD / GAME WORLD', style: TextStyle(fontSize: 7, letterSpacing: 2.6, color: Color(0x668F82A9))),
      const SizedBox(height: 5),
      Text(title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, letterSpacing: 2.2)),
    ])),
  ]);
}

class _GameWorldHero extends StatelessWidget {
  final ContentItem item; final String? artUrl; final bool compact; final double phase;
  const _GameWorldHero({required this.item, required this.artUrl, required this.compact, required this.phase});
  @override Widget build(BuildContext context) {
    final h = compact ? 520.0 : 560.0;
    return Container(height: h, decoration: BoxDecoration(color: const Color(0xD6070711), border: Border.all(color: const Color(0x507F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 35)]), child: compact
      ? Column(children: [Expanded(child: _ArtStage(url: artUrl, title: item.title, phase: phase, compact: true)), _HeroText(item: item, compact: true)])
      : Row(children: [Expanded(flex: 7, child: _ArtStage(url: artUrl, title: item.title, phase: phase, compact: false)), Expanded(flex: 5, child: _HeroText(item: item, compact: false))]));
  }
}

class _ArtStage extends StatelessWidget {
  final String? url; final String title; final double phase; final bool compact;
  const _ArtStage({required this.url, required this.title, required this.phase, required this.compact});
  @override Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: CustomPaint(painter: _ArtStagePainter(phase))),
    Positioned.fill(child: Padding(padding: EdgeInsets.all(compact ? 14 : 24), child: DarkestWorldArtbox(imageUrl: url, title: title, phase: phase, compact: compact))),
    Positioned(left: 16, top: 14, child: _StageLabel(text: 'ARCHIVE OBJECT')),
    Positioned(right: 16, top: 14, child: _StageLabel(text: '01 / 01')),
    Positioned(left: 16, bottom: 14, child: _StageLabel(text: url == null ? 'ARTBOX SOURCE PENDING' : 'TRANSPARENT ART READY')),
    Positioned(right: 16, bottom: 14, child: _StageLabel(text: 'CURRENT')),
  ]);
}

class _ArtStagePainter extends CustomPainter {
  final double phase; const _ArtStagePainter(this.phase);
  @override void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.05, colors: [Color(0xFF302342), Color(0xFF0B0A15), Color(0xFF020207)]).createShader(rect));
    final floor = Rect.fromLTWH(0, s.height * .69, s.width, s.height * .31);
    c.drawRect(floor, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000000), Color(0xAA000000)]).createShader(floor));
    final scan = (phase * s.height * 1.3) % (s.height + 80) - 40;
    c.drawRect(Rect.fromLTWH(0, scan, s.width, 1), Paint()..color = const Color(0x147F70B0));
    for (var i = 0; i < 12; i++) {
      final x = (i + 1) * s.width / 13;
      c.drawLine(Offset(x, s.height * .72), Offset(x, s.height), Paint()..color = const Color(0x0AFFFFFF));
    }
  }
  @override bool shouldRepaint(covariant _ArtStagePainter old) => old.phase != phase;
}

class _HeroText extends StatelessWidget {
  final ContentItem item; final bool compact;
  const _HeroText({required this.item, required this.compact});
  @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.all(compact ? 16 : 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('CURRENT GAME WORLD', style: TextStyle(fontSize: 7, letterSpacing: 3, color: Color(0x7897A8BE))),
    const SizedBox(height: 12),
    Text(item.title.toUpperCase(), maxLines: compact ? 2 : 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 20 : 30, height: 1.02, letterSpacing: 2.2, fontWeight: FontWeight.w300)),
    const SizedBox(height: 15),
    const Text('CINEMATIC ARTBOX ARCHIVE', style: TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0x55FFFFFF))),
    const SizedBox(height: 22),
    Row(children: [const Icon(Icons.inventory_2_outlined, size: 13, color: Color(0x778F82A9)), const SizedBox(width: 7), Text(item.type.name.toUpperCase(), style: const TextStyle(fontSize: 7, letterSpacing: 1.8, color: Color(0x8897A8BE)))])
  ]));
}

class _StageLabel extends StatelessWidget {
  final String text; const _StageLabel({required this.text});
  @override Widget build(BuildContext context) => DecoratedBox(decoration: const BoxDecoration(color: Color(0xCC05060D)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Text(text, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.8, color: Color(0x667F8AA2)))));
}

class _ArtboxInfo extends StatelessWidget {
  final bool compact; final bool hasArt;
  const _ArtboxInfo({required this.compact, required this.hasArt});
  @override Widget build(BuildContext context) => Container(padding: EdgeInsets.all(compact ? 14 : 18), decoration: BoxDecoration(color: const Color(0x88080911), border: Border.all(color: const Color(0x327F70B0))), child: Row(children: [
    Icon(hasArt ? Icons.check_circle_outline : Icons.hourglass_empty, size: 18, color: hasArt ? const Color(0xAA9A8AC4) : const Color(0x557F70B0)),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(hasArt ? 'TRANSPARENT ARTBOX PIPELINE ACTIVE' : 'ARTBOX SOURCE AWAITING ASSET', style: const TextStyle(fontSize: 8, letterSpacing: 1.5)),
      const SizedBox(height: 5),
      Text(hasArt ? 'FULL CASE PRESERVED • 3D PERSPECTIVE • CONTACT SHADOW • REFLECTION • PARALLAX' : 'The renderer is ready for transparent PNG/WebP artbox assets.', style: const TextStyle(fontSize: 6, color: Color(0x778F9AAF))),
    ])),
  ]));
}

class _SectionTitle extends StatelessWidget {
  final String label; final String detail;
  const _SectionTitle({required this.label, required this.detail});
  @override Widget build(BuildContext context) => Row(children: [
    Text(label, style: const TextStyle(fontSize: 8, letterSpacing: 2.5)),
    const SizedBox(width: 10),
    Expanded(child: Container(height: 1, color: const Color(0x1F7F70B0))),
    const SizedBox(width: 10),
    Text(detail, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.4, color: Color(0x557F8AA2))),
  ]);
}

class _Description extends StatelessWidget {
  final String text; const _Description({required this.text});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0x88080911), border: Border.all(color: const Color(0x227F70B0))), child: Text(text, style: const TextStyle(fontSize: 8, height: 1.6, color: Color(0xAAADB7C9))));
}

class _MetaStrip extends StatelessWidget {
  final ContentItem item; final String type; final String franchise;
  const _MetaStrip({required this.item, required this.type, required this.franchise});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13), decoration: BoxDecoration(color: const Color(0x99060810), border: Border.all(color: const Color(0x267F70B0))), child: Wrap(spacing: 22, runSpacing: 9, children: [
    _Meta(label: 'TYPE', value: type.toUpperCase()),
    if (franchise.isNotEmpty) _Meta(label: 'FRANCHISE', value: franchise.toUpperCase()),
    _Meta(label: 'ID', value: item.id),
  ]));
}

class _Meta extends StatelessWidget {
  final String label; final String value;
  const _Meta({required this.label, required this.value});
  @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Text('$label  ', style: const TextStyle(fontSize: 5.5, letterSpacing: 1.6, color: Color(0x557F8AA2))), Text(value, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.1, color: Color(0x8897A8BE)))]);
}

class _IntelGrid extends StatelessWidget {
  final Map<String, String> values; final bool compact;
  const _IntelGrid({required this.values, required this.compact});
  @override Widget build(BuildContext context) {
    final columns = compact ? 2 : 4;
    return GridView.count(crossAxisCount: columns, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: compact ? 2.6 : 3.1, children: values.entries.map((entry) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0x88080911), border: Border.all(color: const Color(0x1D7F70B0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(entry.key, style: const TextStyle(fontSize: 5, letterSpacing: 1.5, color: Color(0x557F8AA2))), const SizedBox(height: 4), Text(entry.value.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6.5, letterSpacing: .8, color: Color(0x8897A8BE)))]))).toList());
  }
}

class _MediaChamber extends StatelessWidget {
  final String? url; final bool compact; final ValueChanged<String> copy;
  const _MediaChamber({required this.url, required this.compact, required this.copy});
  @override Widget build(BuildContext context) => Container(padding: EdgeInsets.all(compact ? 14 : 18), decoration: BoxDecoration(color: const Color(0x88080911), border: Border.all(color: const Color(0x287F70B0))), child: Row(children: [
    const Icon(Icons.play_circle_outline, size: 22, color: Color(0x889A8AC4)), const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(url == null ? 'NO LONGPLAY LINK' : 'LONGPLAY / REFERENCE READY', style: const TextStyle(fontSize: 7.5, letterSpacing: 1.4)),
      const SizedBox(height: 5), Text(url ?? 'Add longplay_url or youtube_url to metadata.', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6, color: Color(0x667F8AA2))),
    ])),
    if (url != null) IconButton(onPressed: () => copy(url!), icon: const Icon(Icons.copy, size: 14, color: Color(0x667F8AA2))),
  ]));
}

class _NavigationRow extends StatelessWidget {
  final TypedFranchiseNavigation navigation; final bool compact; final ValueChanged<ContentItem> open;
  const _NavigationRow({required this.navigation, required this.compact, required this.open});
  @override Widget build(BuildContext context) => Row(children: [
    Expanded(child: _NavCard(label: 'PREVIOUS', item: navigation.previous, compact: compact, open: open)),
    const SizedBox(width: 8),
    Expanded(child: _NavCard(label: 'CURRENT', item: navigation.current, compact: compact, open: null, active: true)),
    const SizedBox(width: 8),
    Expanded(child: _NavCard(label: 'NEXT', item: navigation.next, compact: compact, open: open)),
  ]);
}

class _NavCard extends StatelessWidget {
  final String label; final ContentItem? item; final bool compact; final ValueChanged<ContentItem>? open; final bool active;
  const _NavCard({required this.label, required this.item, required this.compact, required this.open, this.active = false});
  @override Widget build(BuildContext context) {
    final child = Container(height: compact ? 58 : 66, padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: active ? const Color(0x247F70B0) : const Color(0x0C7F70B0), border: Border.all(color: active ? const Color(0x4C9A8AC4) : const Color(0x1D7F70B0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: const TextStyle(fontSize: 5, letterSpacing: 1.5, color: Color(0x557F8AA2))), const SizedBox(height: 5), Text(item?.title.toUpperCase() ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6.5, letterSpacing: .8, color: Color(0x8897A8BE)))]));
    return open == null || item == null ? child : InkWell(onTap: () => open!(item!), child: child);
  }
}

class _RelatedGrid extends StatelessWidget {
  final List<ContentItem> items; final bool compact; final ValueChanged<ContentItem> open;
  const _RelatedGrid({required this.items, required this.compact, required this.open});
  @override Widget build(BuildContext context) => GridView.count(crossAxisCount: compact ? 1 : 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: compact ? 4.4 : 3.8, children: items.map((item) => InkWell(onTap: () => open(item), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0x88080911), border: Border.all(color: const Color(0x1D7F70B0))), child: Row(children: [const Icon(Icons.link, size: 13, color: Color(0x667F70B0)), const SizedBox(width: 9), Expanded(child: Text(item.title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.0, color: Color(0x8897A8BE))))])))).toList());
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();
  @override Widget build(BuildContext context) => Container(height: 70, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0x88080911), border: Border.all(color: const Color(0x1D7F70B0))), child: const Text('LOADING ARCHIVE SIGNAL…', style: TextStyle(fontSize: 6, letterSpacing: 1.8, color: Color(0x557F8AA2))));
}

class _MessagePanel extends StatelessWidget {
  final String text; const _MessagePanel({required this.text});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0x88080911), border: Border.all(color: const Color(0x1D7F70B0))), child: Text(text, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.2, color: Color(0x557F8AA2))));
}

class _DetailSpacePainter extends CustomPainter {
  final double phase; const _DetailSpacePainter(this.phase);
  @override void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..shader = const RadialGradient(center: Alignment(0, -.35), radius: 1.25, colors: [Color(0xFF11101E), Color(0xFF05050C), Color(0xFF020207)]).createShader(Offset.zero & s));
    final glow = Paint()..color = const Color(0x087F70B0);
    c.drawCircle(Offset(s.width * .82, s.height * .18), 180 + math.sin(phase * math.pi * 2) * 12, glow);
  }
  @override bool shouldRepaint(covariant _DetailSpacePainter old) => old.phase != phase;
}

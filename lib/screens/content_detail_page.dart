import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/chat_scope.dart';
import '../core/content_models.dart';
import '../core/content_repository.dart';
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
  String? get _artUrl { for (final value in [widget.item.metadata['public_url'], widget.item.metadata['image_url'], widget.item.metadata['artwork_url'], widget.item.metadata['cover_url']]) { if (value is String && value.isNotEmpty) return value; } return null; }
  @override void initState() { super.initState(); if (_isExternal) { _relatedLoading = false; _navigationLoading = false; } else { _loadRelated(); _loadNavigation(); } }
  @override void dispose() { _clock.dispose(); super.dispose(); }
  Future<void> _loadRelated() async { try { final result = await _repository.getRelatedContentItems(widget.item.id); if (!mounted) return; setState(() { _related = result; _relatedLoading = false; }); } catch (e) { if (!mounted) return; setState(() { _relatedLoading = false; _relatedError = e.toString(); }); } }
  Future<void> _loadNavigation() async { try { final result = await _repository.getTypedFranchiseNavigation(widget.item); if (!mounted) return; setState(() { _navigation = result; _navigationLoading = false; }); } catch (e) { if (!mounted) return; setState(() { _navigationLoading = false; _navigationError = e.toString(); }); } }
  ChatContext? get _chatContext { if (_isExternal) return null; ChatScope? scope; if (_type == 'game') scope = ChatScope.games; if (_type == 'movie') scope = ChatScope.movies; if (_type == 'series') scope = ChatScope.series; if (scope == null) return null; return ChatContext(scope: scope, contentId: widget.item.id, contentTitle: _title); }
  void _open(ContentItem item) => Navigator.push(context, MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));
  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (_, __) => Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _DetailSpacePainter(_clock.value))),
          SafeArea(child: ListView(padding: EdgeInsets.fromLTRB(compact ? 14 : 42, 14, compact ? 14 : 42, 55), children: [
            _Header(title: _title, onBack: () => Navigator.pop(context)), const SizedBox(height: 22),
            _WorldHero(item: widget.item, artUrl: _artUrl, compact: compact, phase: _clock.value), const SizedBox(height: 22),
            _MetaStrip(item: widget.item, type: _type, franchise: _franchise),
            if (_description.isNotEmpty) ...[const SizedBox(height: 22), _Description(text: _description)],
            const SizedBox(height: 26), _SectionTitle(label: 'NAVIGATION', detail: 'PREVIOUS  |  CURRENT  |  NEXT'), const SizedBox(height: 11),
            if (_navigationLoading) const _LoadingPanel() else if (_navigationError != null) const _MessagePanel(text: 'FRANCHISE NAVIGATION UNAVAILABLE') else if (_navigation == null) const _MessagePanel(text: 'NO FRANCHISE ORDER AVAILABLE') else _NavigationRow(navigation: _navigation!, compact: compact, open: _open),
            const SizedBox(height: 28), _SectionTitle(label: 'RELATED', detail: 'CONNECTED WORLDS'), const SizedBox(height: 11),
            if (_relatedLoading) const _LoadingPanel() else if (_relatedError != null) const _MessagePanel(text: 'RELATED CONTENT UNAVAILABLE') else if (_related.isEmpty) const _MessagePanel(text: 'NO RELATED WORLDS YET') else _RelatedGrid(items: _related, compact: compact, open: _open),
            if (_isExternal) ...[const SizedBox(height: 24), const _MessagePanel(text: 'LIVE EXTERNAL RESULT — NOT STORED IN THE DARKESTWORLD DATABASE')],
          ])),
        ]),
      ),
      floatingActionButton: _chatContext == null ? null : Chatbox(contextData: _chatContext!),
    );
  }
}

class _Header extends StatelessWidget { final String title; final VoidCallback onBack; const _Header({required this.title, required this.onBack}); @override Widget build(BuildContext context) => Row(children: [IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new, size: 15, color: Color(0xBBFFFFFF))), const SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('DARKESTWORLD / GAME WORLD', style: TextStyle(fontSize: 7, letterSpacing: 2.6, color: Color(0x668F82A9))), const SizedBox(height: 5), Text(title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, letterSpacing: 2.2))]))]); }
class _WorldHero extends StatelessWidget { final ContentItem item; final String? artUrl; final bool compact; final double phase; const _WorldHero({required this.item, required this.artUrl, required this.compact, required this.phase}); @override Widget build(BuildContext context) { final h = compact ? 430.0 : 520.0; return Container(height: h, decoration: BoxDecoration(color: const Color(0xCC070711), border: Border.all(color: const Color(0x507F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 35)]), child: compact ? Column(children: [Expanded(child: _ArtStage(url: artUrl, title: item.title, phase: phase)), _HeroText(item: item, compact: true)]) : Row(children: [Expanded(flex: 6, child: _ArtStage(url: artUrl, title: item.title, phase: phase)), Expanded(flex: 5, child: _HeroText(item: item, compact: false))])); } }
class _ArtStage extends StatelessWidget {
  final String? url;
  final String title;
  final double phase;
  const _ArtStage({required this.url, required this.title, required this.phase});
  @override Widget build(BuildContext context) => Stack(children: [
    Positioned.fill(child: CustomPaint(painter: _ArtStagePainter(phase))),
    Positioned.fill(child: Padding(padding: const EdgeInsets.all(24), child: Center(child: _ArtObject(url: url, title: title)))),
    Positioned(left: 16, top: 14, child: _StageLabel(text: 'ARCHIVE OBJECT')),
    Positioned(right: 16, top: 14, child: _StageLabel(text: '01 / 01')),
    Positioned(left: 16, bottom: 14, child: _StageLabel(text: 'TRANSPARENT ART READY')),
    Positioned(right: 16, bottom: 14, child: _StageLabel(text: 'CURRENT')),
  ]);
}
class _ArtObject extends StatelessWidget { final String? url; final String title; const _ArtObject({required this.url, required this.title}); @override Widget build(BuildContext context) { if (url == null) return Text(title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, letterSpacing: 2, color: Color(0x77FFFFFF))); return Image.network(url!, fit: BoxFit.contain, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Text(title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, letterSpacing: 2, color: Color(0x77FFFFFF))); } }
class _StageLabel extends StatelessWidget { final String text; const _StageLabel({required this.text}); @override Widget build(BuildContext context) => DecoratedBox(decoration: const BoxDecoration(color: Color(0x9905060D)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), child: Text(text, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.8, color: Color(0x667F8AA2))))); }
class _ArtStagePainter extends CustomPainter { final double phase; const _ArtStagePainter(this.phase); @override void paint(Canvas c, Size s) { final rect = Offset.zero & s; c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.05), radius: 1.05, colors: [Color(0xFF29203F), Color(0xFF0B0A15), Color(0xFF020207)]).createShader(rect)); final floor = Rect.fromLTWH(0, s.height * .70, s.width, s.height * .30); c.drawRect(floor, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x22000000), Color(0x99000000)]).createShader(floor)); final cx = s.width / 2; final cy = s.height * .62; final rx = s.width * .36; final ry = s.height * .065; c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), Paint()..style = PaintingStyle.fill..color = const Color(0x44000000)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)); c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 1.3, height: ry * 1.1), Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x247F70B0)); final scan = (phase * s.height * 1.4) % (s.height + 80) - 40; c.drawRect(Rect.fromLTWH(0, scan, s.width, 1), Paint()..color = const Color(0x147F70B0)); for (var i = 0; i < 14; i++) { final x = (i + 1) * s.width / 15; c.drawLine(Offset(x, s.height * .72), Offset(x, s.height), Paint()..color = const Color(0x0AFFFFFF)); } } @override bool shouldRepaint(covariant _ArtStagePainter old) => old.phase != phase; }
class _HeroText extends StatelessWidget { final ContentItem item; final bool compact; const _HeroText({required this.item, required this.compact}); @override Widget build(BuildContext context) => Padding(padding: EdgeInsets.all(compact ? 16 : 30), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [const Text('CURRENT WORLD', style: TextStyle(fontSize: 7, letterSpacing: 3, color: Color(0x7897A8BE))), const SizedBox(height: 12), Text(item.title.toUpperCase(), maxLines: compact ? 2 : 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 20 : 30, height: 1.02, letterSpacing: 2.2, fontWeight: FontWeight.w300)), const SizedBox(height: 15), const Text('DARK CORE ARCHIVE', style: TextStyle(fontSize: 7, letterSpacing: 2, color: Color(0x55FFFFFF))), const SizedBox(height: 22), Row(children: [const Icon(Icons.public, size: 13, color: Color(0x778F82A9)), const SizedBox(width: 7), Text(item.type.name.toUpperCase(), style: const TextStyle(fontSize: 7, letterSpacing: 1.8, color: Color(0x8897A8BE)))]) ])); }
class _MetaStrip extends StatelessWidget { final ContentItem item; final String type; final String franchise; const _MetaStrip({required this.item, required this.type, required this.franchise}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), decoration: BoxDecoration(color: const Color(0xAA080811), border: Border.all(color: const Color(0x267F70B0))), child: Wrap(spacing: 22, runSpacing: 10, children: [_Meta(label: 'TYPE', value: type.toUpperCase()), if (franchise.isNotEmpty) _Meta(label: 'FRANCHISE', value: franchise.toUpperCase()), if (item.releaseDate != null) _Meta(label: 'RELEASE', value: item.releaseDate!.toIso8601String().split('T').first), if (item.originalTitle != null && item.originalTitle!.isNotEmpty && item.originalTitle != item.title) _Meta(label: 'ORIGINAL', value: item.originalTitle!)])); }
class _Meta extends StatelessWidget { final String label; final String value; const _Meta({required this.label, required this.value}); @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 5.5, letterSpacing: 2, color: Color(0x557F70B0))), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 8.5, letterSpacing: .8, color: Color(0xCCFFFFFF)))]); }
class _Description extends StatelessWidget { final String text; const _Description({required this.text}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: Color(0x66090A13)), child: Text(text, style: const TextStyle(fontSize: 11, height: 1.65, color: Color(0xAAFFFFFF)))); }
class _SectionTitle extends StatelessWidget { final String label; final String detail; const _SectionTitle({required this.label, required this.detail}); @override Widget build(BuildContext context) => Row(children: [Text(label, style: const TextStyle(fontSize: 10, letterSpacing: 3)), const SizedBox(width: 12), Text(detail, style: const TextStyle(fontSize: 6.5, letterSpacing: 1.8, color: Color(0x557F70B0)))]); }
class _LoadingPanel extends StatelessWidget { const _LoadingPanel(); @override Widget build(BuildContext context) => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())); }
class _MessagePanel extends StatelessWidget { final String text; const _MessagePanel({required this.text}); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: const Color(0x66080912), border: Border.all(color: const Color(0x227F70B0))), child: Text(text, style: const TextStyle(fontSize: 7, letterSpacing: 1.7, color: Color(0x668F82A9)))); }
class _NavigationRow extends StatelessWidget { final TypedFranchiseNavigation navigation; final bool compact; final ValueChanged<ContentItem> open; const _NavigationRow({required this.navigation, required this.compact, required this.open}); @override Widget build(BuildContext context) => Row(children: [Expanded(child: _NavCard(item: navigation.previous, label: 'PREVIOUS', compact: compact, onOpen: navigation.previous == null ? null : () => open(navigation.previous!))), const SizedBox(width: 10), Expanded(flex: 2, child: _NavCard(item: navigation.current, label: 'CURRENT', current: true, compact: compact, onOpen: null)), const SizedBox(width: 10), Expanded(child: _NavCard(item: navigation.next, label: 'NEXT', compact: compact, onOpen: navigation.next == null ? null : () => open(navigation.next!)))]); }
class _NavCard extends StatelessWidget {
  final ContentItem? item;
  final String label;
  final bool current;
  final bool compact;
  final VoidCallback? onOpen;
  const _NavCard({required this.item, required this.label, this.current = false, required this.compact, required this.onOpen});
  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: compact ? 130 : 170,
      padding: EdgeInsets.all(current ? 18 : 13),
      decoration: BoxDecoration(
        color: current ? const Color(0xAA151125) : const Color(0x88080911),
        border: Border.all(color: current ? const Color(0x7D8A78B5) : const Color(0x267F70B0)),
        boxShadow: current ? const [BoxShadow(color: Color(0x401F163B), blurRadius: 22)] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: TextStyle(fontSize: current ? 7 : 5.5, letterSpacing: 2.2, color: const Color(0x778F82A9))),
          const SizedBox(height: 9),
          Text(item?.title ?? '—', maxLines: 3, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: current ? 15 : 9, height: 1.1, letterSpacing: current ? 1.2 : .7, color: item == null ? const Color(0x44FFFFFF) : Colors.white)),
        ],
      ),
    );
    return GestureDetector(onTap: onOpen, child: card);
  }
}
class _RelatedGrid extends StatelessWidget { final List<ContentItem> items; final bool compact; final ValueChanged<ContentItem> open; const _RelatedGrid({required this.items, required this.compact, required this.open}); @override Widget build(BuildContext context) => GridView.builder(physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, itemCount: items.length, gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: compact ? 190 : 260, mainAxisExtent: compact ? 120 : 145, crossAxisSpacing: 10, mainAxisSpacing: 10), itemBuilder: (_, i) { final item = items[i]; final url = item.metadata['public_url'] ?? item.metadata['image_url']; return GestureDetector(onTap: () => open(item), child: Container(decoration: BoxDecoration(color: const Color(0x99080911), border: Border.all(color: const Color(0x267F70B0))), child: Row(children: [SizedBox(width: compact ? 65 : 82, height: double.infinity, child: url is String && url.isNotEmpty ? Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.public, color: Color(0x447F70B0))) : const Icon(Icons.public, color: Color(0x447F70B0))), Expanded(child: Padding(padding: const EdgeInsets.all(10), child: Text(item.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, letterSpacing: .7, color: Color(0xCCFFFFFF)))))]))); }); }
class _DetailSpacePainter extends CustomPainter { final double phase; const _DetailSpacePainter(this.phase); @override void paint(Canvas c, Size s) { c.drawRect(Offset.zero & s, Paint()..shader = const RadialGradient(center: Alignment(0, -.15), radius: 1.2, colors: [Color(0xFF20192F), Color(0xFF090910), Color(0xFF010106)]).createShader(Offset.zero & s)); final r = math.Random(42); for (var i = 0; i < 150; i++) { final x = r.nextDouble() * s.width; final y = r.nextDouble() * s.height; c.drawCircle(Offset(x, y), .35 + r.nextDouble(), Paint()..color = Colors.white.withValues(alpha: .06 + r.nextDouble() * .2)); } final y = (phase * s.height * 1.25) % (s.height + 120) - 60; c.drawRect(Rect.fromLTWH(0, y, s.width, 1), Paint()..color = const Color(0x127F70B0)); c.drawRect(Offset.zero & s, Paint()..shader = const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0x22000000), Color(0x99000000)]).createShader(Offset.zero & s)); } @override bool shouldRepaint(covariant _DetailSpacePainter old) => old.phase != phase; }

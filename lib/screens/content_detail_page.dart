import 'dart:math' as math;
import 'package:flutter/material.dart';
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
  final repository = ContentRepository();
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 70))..repeat();
  List<ContentItem> related = const [];
  TypedFranchiseNavigation? navigation;
  bool relatedLoading = true;
  bool navigationLoading = true;
  final FocusNode _focusNode = FocusNode();

  bool get external => widget.item.externalSource != null && widget.item.externalId != null;

  String? get artUrl {
    for (final key in ['transparent_artbox_url', 'artbox_url', 'public_url', 'image_url', 'artwork_url', 'cover_url']) {
      final value = widget.item.metadata[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  DarkestWorldNavigationState? get archiveState {
    final nav = navigation;
    if (nav == null) return null;
    return DarkestWorldNavigationState(
      previous: nav.previous,
      current: widget.item,
      next: nav.next,
      related: related,
      source: 'content_detail',
      entryPoint: 'detail',
      originId: widget.item.id,
    );
  }

  @override
  void initState() {
    super.initState();
    if (external) {
      relatedLoading = false;
      navigationLoading = false;
    } else {
      _loadRelated();
      _loadNavigation();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    clock.dispose();
    super.dispose();
  }

  Future<void> _loadRelated() async {
    try {
      final result = await repository.getRelatedContentItems(widget.item.id);
      if (!mounted) return;
      setState(() { related = result; relatedLoading = false; });
    } catch (_) {
      if (mounted) setState(() => relatedLoading = false);
    }
  }

  Future<void> _loadNavigation() async {
    try {
      final result = await repository.getTypedFranchiseNavigation(widget.item);
      if (!mounted) return;
      setState(() { navigation = result; navigationLoading = false; });
    } catch (_) {
      if (mounted) setState(() => navigationLoading = false);
    }
  }

  void _open(ContentItem item) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ContentDetailPage(item: item)));

  ChatContext? get chatContext {
    if (external) return null;
    final scope = switch (widget.item.type) {
      ContentType.game => ChatScope.games,
      ContentType.movie => ChatScope.movies,
      ContentType.series => ChatScope.series,
      ContentType.unknown => null,
    };
    return scope == null ? null : ChatContext(scope: scope, contentId: widget.item.id, contentTitle: widget.item.title);
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 850;
    final state = archiveState;
    final year = widget.item.releaseYear?.toString() ?? '${widget.item.metadata['year'] ?? 'ARCHIVE'}';
    return Scaffold(
      backgroundColor: const Color(0xFF020208),
      body: Focus(
        autofocus: true,
        focusNode: _focusNode,
        onKeyEvent: (_, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          }
          if (navigation == null) return KeyEventResult.ignored;
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft && navigation!.previous != null) {
            _open(navigation!.previous!);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.arrowRight && navigation!.next != null) {
            _open(navigation!.next!);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: clock,
              builder: (_, __) => CustomPaint(
                painter: _DetailAtmospherePainter(clock.value),
              ),
            ),
            ListView(
          padding: EdgeInsets.fromLTRB(compact ? 12 : 34, 14, compact ? 12 : 34, 50),
          children: [
            Row(children: [
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 15)),
              Expanded(child: Text(widget.item.title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, letterSpacing: 2.2))),
              Text(year, style: const TextStyle(fontSize: 7, letterSpacing: 1.3, color: Color(0x667F8AA2))),
            ]),
            const SizedBox(height: 18),
            Container(
              height: compact ? 500 : 560,
              decoration: BoxDecoration(color: const Color(0xD6070711), border: Border.all(color: const Color(0x507F70B0)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 35)]),
              child: compact
                  ? Column(children: [Expanded(child: AnimatedBuilder(animation: clock, builder: (_, __) => DarkestWorldArtbox(imageUrl: artUrl, title: widget.item.title, phase: clock.value, compact: true))), _HeroInfo(item: widget.item, compact: true)])
                  : Row(children: [Expanded(flex: 7, child: AnimatedBuilder(animation: clock, builder: (_, __) => DarkestWorldArtbox(imageUrl: artUrl, title: widget.item.title, phase: clock.value))), Expanded(flex: 5, child: _HeroInfo(item: widget.item, compact: false))]),
            ),
            const SizedBox(height: 24),
            _Panel(title: 'ARCHIVE INTEL', child: Wrap(spacing: 8, runSpacing: 8, children: [
              _Chip('TYPE', widget.item.type.name.toUpperCase()),
              if (widget.item.franchise?.isNotEmpty ?? false) _Chip('FRANCHISE', widget.item.franchise!.toUpperCase()),
              _Chip('RELEASE', year),
              _Chip('ARTBOX', artUrl == null ? 'PENDING' : 'READY'),
            ])),
            if (widget.item.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: 18),
              _Panel(title: 'DESCRIPTION', child: Text(widget.item.description!, style: const TextStyle(fontSize: 10, height: 1.5, color: Color(0xAAFFFFFF)))),
            ],
            if (state != null) ...[
              const SizedBox(height: 24),
              _Panel(title: 'ARCHIVE SIGNAL', child: AnimatedBuilder(animation: clock, builder: (_, __) => ArchiveSignalTelemetryLens(state: state, phase: clock.value, compact: compact, onPreviousTap: navigation?.previous == null ? null : _open, onNextTap: navigation?.next == null ? null : _open, onRelatedTap: _open))),
            ],
            const SizedBox(height: 24),
            _Panel(
              title: 'NAVIGATION',
              child: navigationLoading
                  ? const LinearProgressIndicator()
                  : navigation == null
                      ? const Text('NO FRANCHISE ORDER AVAILABLE')
                      : Row(children: [
                          Expanded(child: _NavButton(label: 'PREVIOUS', item: navigation!.previous, onTap: navigation!.previous == null ? null : () => _open(navigation!.previous!))),
                          const SizedBox(width: 8),
                          Expanded(child: _NavButton(label: 'CURRENT', item: widget.item, onTap: null, active: true)),
                          const SizedBox(width: 8),
                          Expanded(child: _NavButton(label: 'NEXT', item: navigation!.next, onTap: navigation!.next == null ? null : () => _open(navigation!.next!))),
                        ]),
            ),
            const SizedBox(height: 24),
            _Panel(
              title: 'RELATED',
              child: relatedLoading
                  ? const LinearProgressIndicator()
                  : related.isEmpty
                      ? const Text('NO RELATED WORLDS YET')
                      : Wrap(spacing: 8, runSpacing: 8, children: [for (final item in related.take(12)) ActionChip(label: Text(item.title), onPressed: () => _open(item))]),
            ),
          ],
        ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        const Color(0x5502040A),
                        const Color(0xB302040A),
                      ],
                      stops: const [.25, .72, 1],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: chatContext == null ? null : Chatbox(contextData: chatContext!),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  final ContentItem item;
  final bool compact;
  const _HeroInfo({required this.item, required this.compact});
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.all(compact ? 16 : 28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CURRENT GAME WORLD', style: TextStyle(fontSize: 7, letterSpacing: 2.6, color: Color(0x778F82A9))),
          const SizedBox(height: 12),
          Text(item.title.toUpperCase(), maxLines: compact ? 2 : 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: compact ? 20 : 29, fontWeight: FontWeight.w300, height: 1.03, letterSpacing: 1.8)),
          const SizedBox(height: 16),
          Text(item.type.name.toUpperCase(), style: const TextStyle(fontSize: 7, letterSpacing: 1.8, color: Color(0x8897A8BE))),
        ]),
      );
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0x99070810), border: Border.all(color: const Color(0x287F70B0))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 7, letterSpacing: 2.1, color: Color(0x778F8AA2))), const SizedBox(height: 12), child]));
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  const _Chip(this.label, this.value);
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0x0C7F70B0), border: Border.all(color: const Color(0x247F70B0))), child: Text('$label  $value', style: const TextStyle(fontSize: 6.5, letterSpacing: 1.0)));
}

class _NavButton extends StatelessWidget {
  final String label;
  final ContentItem? item;
  final VoidCallback? onTap;
  final bool active;
  const _NavButton({required this.label, required this.item, required this.onTap, this.active = false});
  @override
  Widget build(BuildContext context) => OutlinedButton(onPressed: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Column(children: [Text(label, style: const TextStyle(fontSize: 5.5, letterSpacing: 1.4)), const SizedBox(height: 4), Text(item?.title ?? '—', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: active ? 8 : 7))])));
}


class _DetailAtmospherePainter extends CustomPainter {
  final double phase;
  const _DetailAtmospherePainter(this.phase);

  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width * .52, s.height * .40);
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFF020208));
    final r = math.max(s.width, s.height) * .72;
    c.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0x221C1740),
            Color(0x0D0B1730),
            Colors.transparent,
          ],
          stops: const [0, .48, 1],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0x143E4C78);
    final drift = math.sin(phase * math.pi * 2) * 18;
    for (var i = 0; i < 3; i++) {
      final rect = Rect.fromCenter(
        center: center + Offset(drift * (i + 1) * .25, i * 34.0),
        width: s.width * (.72 + i * .10),
        height: s.height * (.38 + i * .08),
      );
      c.drawArc(rect, math.pi * (.18 + i * .11), math.pi * 1.18, false, arcPaint);
    }
    for (var i = 0; i < 36; i++) {
      final a = i * 2.399 + phase * math.pi * 2 * .035;
      final rr = s.shortestSide * (.22 + (i % 7) * .065);
      final p = center + Offset(math.cos(a) * rr, math.sin(a) * rr * .58);
      c.drawCircle(p, .7 + (i % 3) * .35, Paint()..color = Colors.white.withValues(alpha: .025 + (i % 4) * .008));
    }
  }

  @override
  bool shouldRepaint(covariant _DetailAtmospherePainter oldDelegate) => oldDelegate.phase != phase;
}

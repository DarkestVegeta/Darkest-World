import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/galaxy_render_state.dart';
import '../screens/galaxy_navigation_session.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld {
  final GalaxyWorldKind kind;
  final String title;
  final String description;
  const GalaxyWorld({required this.kind, required this.title, required this.description});
}

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key, required this.worlds, this.onWorldTap});
  @override State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> with SingleTickerProviderStateMixin {
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 140))..repeat();
  final session = GalaxyNavigationSession.instance;
  GalaxyWorldKind? selected, hovered;
  GalaxyRenderState get render => session.renderState;
  @override void initState() { super.initState(); session.addListener(_changed); }
  @override void didChangeDependencies() { super.didChangeDependencies(); final compact = MediaQuery.sizeOf(context).width < 760; if (render.compact != compact) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) session.updateRenderState(render.copyWith(compact: compact)); }); }
  @override void dispose() { session.removeListener(_changed); clock.dispose(); super.dispose(); }
  void _changed() { if (mounted) setState(() {}); }
  void _select(GalaxyWorld w) { setState(() => selected = w.kind); session.select(w.kind); }
  void _open(GalaxyWorld w) { session.visit(w.kind); widget.onWorldTap?.call(w); }
  void _clear() { setState(() { selected = null; hovered = null; }); session.clearSelection(); }
  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final s = render;
    GalaxyWorld? current;
    for (final w in widget.worlds) { if (w.kind == selected) { current = w; break; } }
    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _GalaxyBackground(clock.value)),
        CustomPaint(painter: _GalaxyStructure(clock.value, s.zoom, widget.worlds.length)),
        _WorldNodes(worlds: widget.worlds, phase: clock.value, zoom: s.zoom, compact: compact, selected: selected, hovered: hovered, onSelect: _select, onOpen: _open, onHover: (w) => setState(() => hovered = w?.kind)),
        Positioned(left: compact ? 18 : 44, top: compact ? 18 : 38, child: const _Title()),
        Positioned(right: compact ? 18 : 44, top: compact ? 18 : 38, child: _Controls(reset: () { session.resetRenderState(compact: compact); _clear(); }, plus: () => session.updateRenderState(s.copyWith(zoom: (s.zoom + .08).clamp(.78, 1.42).toDouble())), minus: () => session.updateRenderState(s.copyWith(zoom: (s.zoom - .08).clamp(.78, 1.42).toDouble())))),
        if (current != null) Positioned(left: compact ? 18 : 44, right: compact ? 18 : 44, bottom: compact ? 18 : 34, child: _Info(world: current, index: widget.worlds.indexOf(current), count: widget.worlds.length, close: _clear))
        else const Positioned(left: 0, right: 0, bottom: 30, child: Center(child: _Hint())),
      ])),
    );
  }
}

class _WorldNodes extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, zoom; final bool compact; final GalaxyWorldKind? selected, hovered;
  final ValueChanged<GalaxyWorld> onSelect, onOpen; final ValueChanged<GalaxyWorld?> onHover;
  const _WorldNodes({required this.worlds, required this.phase, required this.zoom, required this.compact, required this.selected, required this.hovered, required this.onSelect, required this.onOpen, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (context, b) {
    final m = math.min(b.maxWidth, b.maxHeight), center = Offset(b.maxWidth * .5, b.maxHeight * .51), orbit = m * (compact ? .29 : .37) * zoom;
    final out = <Widget>[];
    for (var i = 0; i < worlds.length; i++) {
      final w = worlds[i]; final a = -math.pi / 2 + i * math.pi * 2 / worlds.length + phase * math.pi * .025;
      final rr = orbit * (.83 + (i % 3) * .085); final p = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr * .63);
      final d = m * (.095 + (math.sin(a) + 1) * .010 + (selected == w.kind ? .024 : 0));
      out.add(Positioned(left: p.dx - d / 2, top: p.dy - d / 2, width: d, height: d,
        child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(w), onExit: (_) => onHover(null),
          child: GestureDetector(onTap: () => onSelect(w), onDoubleTap: () => onOpen(w), child: CustomPaint(painter: _WorldPainter(w.kind, w.title, selected == w.kind, hovered == w.kind, (math.sin(a) + 1) / 2, phase))))));
    }
    return Stack(children: out);
  });
}

class _Title extends StatelessWidget {
  const _Title();
  @override Widget build(BuildContext c) => IgnorePointer(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 6, fontWeight: FontWeight.w500)),
    SizedBox(height: 8), Text('THE WORLDS / ATLAS', style: TextStyle(color: Color(0x78FFFFFF), fontSize: 7, letterSpacing: 3.4)),
  ]));
}

class _Controls extends StatelessWidget {
  final VoidCallback reset, plus, minus; const _Controls({required this.reset, required this.plus, required this.minus});
  @override Widget build(BuildContext c) => Row(children: [_C('+', plus), const SizedBox(width: 5), _C('−', minus), const SizedBox(width: 5), _C('RESET', reset)]);
}
class _C extends StatelessWidget { final String t; final VoidCallback f; const _C(this.t, this.f); @override Widget build(BuildContext c) => InkWell(onTap: f, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0x5506070E), border: Border.all(color: const Color(0x30FFFFFF))), child: Text(t, style: const TextStyle(color: Color(0x90FFFFFF), fontSize: 6.5, letterSpacing: 1.5)))); }

class _Info extends StatelessWidget {
  final GalaxyWorld world; final int index, count; final VoidCallback close;
  const _Info({required this.world, required this.index, required this.count, required this.close});
  @override Widget build(BuildContext c) => Container(padding: const EdgeInsets.fromLTRB(20, 16, 12, 16), decoration: BoxDecoration(color: const Color(0xE0090912), border: Border.all(color: const Color(0x38FFFFFF)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 40)]), child: Row(children: [
    Container(width: 3, height: 54, decoration: BoxDecoration(color: const Color(0x997E62A6), borderRadius: BorderRadius.circular(2))), const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0x55FFFFFF), fontSize: 6, letterSpacing: 1.8)), const SizedBox(height: 5), Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 3)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x78FFFFFF), fontSize: 8))])),
    InkWell(onTap: close, child: const Padding(padding: EdgeInsets.all(9), child: Text('×', style: TextStyle(color: Color(0x90FFFFFF), fontSize: 19)))),
  ]));
}
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext c) => const Text('1× CLICK  FOCUS     2× CLICK  ENTER WORLD', style: TextStyle(color: Color(0x58FFFFFF), fontSize: 7, letterSpacing: 2)); }

class _GalaxyBackground extends CustomPainter {
  final double phase; const _GalaxyBackground(this.phase);
  @override void paint(Canvas x, Size s) {
    final rect = Offset.zero & s;
    x.drawRect(rect, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF010207), Color(0xFF090613), Color(0xFF02030A)]).createShader(rect));
    final rnd = math.Random(7719);
    for (var i = 0; i < 760; i++) { final alpha = .025 + rnd.nextDouble() * .19; x.drawCircle(Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height), .18 + rnd.nextDouble() * 1.15, Paint()..color = Colors.white.withValues(alpha: alpha)); }
    final c = Offset(s.width * .5, s.height * .51), r = math.min(s.width, s.height) * .67;
    x.drawCircle(c, r, Paint()..shader = RadialGradient(colors: [const Color(0xFF9A62BA).withValues(alpha: .11), const Color(0xFF45366B).withValues(alpha: .035), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r)));
    for (var i = 0; i < 5; i++) { final y = s.height * (.16 + i * .18) + math.sin(phase * math.pi * 2 + i) * 10; x.drawOval(Rect.fromCenter(center: Offset(s.width * .5, y), width: s.width * (.7 + i * .05), height: s.height * .16), Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Color(0x081C172C)); }
  }
  @override bool shouldRepaint(covariant _GalaxyBackground o) => o.phase != phase;
}

class _GalaxyStructure extends CustomPainter {
  final double phase, zoom; final int count; const _GalaxyStructure(this.phase, this.zoom, this.count);
  @override void paint(Canvas x, Size s) {
    final c = Offset(s.width * .5, s.height * .51), m = math.min(s.width, s.height), rx = m * .39 * zoom, ry = m * .245 * zoom;
    for (var i = 0; i < 4; i++) { final f = 1 - i * .18; x.drawOval(Rect.fromCenter(center: c, width: rx * 2 * f, height: ry * 2 * f), Paint()..style = PaintingStyle.stroke..strokeWidth = .45 + i * .2..color = Color(0x14B99BD0)); }
    for (var i = 0; i < count; i++) { final a = -math.pi / 2 + i * math.pi * 2 / count; final p = Offset(c.dx + math.cos(a) * rx, c.dy + math.sin(a) * ry); x.drawLine(c, p, Paint()..shader = LinearGradient(colors: [const Color(0x125E4B72), const Color(0x00CBB4DE)]).createShader(Rect.fromPoints(c, p))..strokeWidth = .55); }
    x.drawCircle(c, m * .115, Paint()..shader = RadialGradient(colors: [const Color(0xFFD9C3E4).withValues(alpha: .24), const Color(0xFF8A5AA3).withValues(alpha: .08), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: m * .115)));
    x.drawCircle(c, m * .045, Paint()..shader = const RadialGradient(center: Alignment(-.35, -.4), colors: [Color(0xFFF2E8F5), Color(0xFFA77BB5), Color(0xFF25172B)]).createShader(Rect.fromCircle(center: c, radius: m * .045)));
    x.drawArc(Rect.fromCenter(center: c, width: rx * 1.75, height: ry * 1.75), phase * math.pi * 2, math.pi * .62, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x55E1D1E7));
    x.drawArc(Rect.fromCenter(center: c, width: rx * 1.25, height: ry * 1.25), -phase * math.pi * 1.35, math.pi * .34, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .7..color = const Color(0x3D9E78B2));
  }
  @override bool shouldRepaint(covariant _GalaxyStructure o) => o.phase != phase || o.zoom != zoom || o.count != count;
}

class _WorldPainter extends CustomPainter {
  final GalaxyWorldKind kind; final String title; final bool selected, hovered; final double depth, phase;
  _WorldPainter(this.kind, this.title, this.selected, this.hovered, this.depth, this.phase);
  Color get accent => switch (kind) {
    GalaxyWorldKind.game => const Color(0xFF789BC4), GalaxyWorldKind.music => const Color(0xFFB487CE), GalaxyWorldKind.cinema => const Color(0xFFC0A4D2),
    GalaxyWorldKind.identity => const Color(0xFF8EA7BD), GalaxyWorldKind.family => const Color(0xFF9A82B7), GalaxyWorldKind.creation => const Color(0xFFC09A70),
    GalaxyWorldKind.archive => const Color(0xFF8D8A99), GalaxyWorldKind.comingSoon => const Color(0xFF76727F), GalaxyWorldKind.vegeta => const Color(0xFFC7A1D8),
  };
  @override void paint(Canvas x, Size s) {
    final c = s.center(Offset.zero), r = math.min(s.width, s.height) * .31;
    final atmosphere = r * (selected ? 3.4 : hovered ? 2.6 : 1.85);
    x.drawCircle(c, atmosphere, Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: selected ? .27 : .12), accent.withValues(alpha: .025), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: atmosphere)));
    final body = Paint()..shader = RadialGradient(center: const Alignment(-.36, -.42), radius: 1.05, colors: [Color.lerp(Colors.white, accent, .12 + depth * .2)!, accent.withValues(alpha: .88), Color.lerp(accent, const Color(0xFF08080F), .82)!]).createShader(Rect.fromCircle(center: c, radius: r));
    x.drawCircle(c, r, body);
    final land = Paint()..color = Colors.white.withValues(alpha: .075);
    for (var i = 0; i < 5; i++) { final yy = c.dy - r * .72 + i * r * .34 + math.sin(phase * math.pi * 2 + i * 1.7) * r * .035; x.drawOval(Rect.fromCenter(center: Offset(c.dx + math.sin(i * 2.4) * r * .18, yy), width: r * (.75 - i * .07), height: r * .12), land); }
    x.drawArc(Rect.fromCircle(center: c, radius: r * .72), math.pi * (.12 + depth * .2), math.pi * .72, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .10..color = const Color(0x3A100B18));
    x.drawCircle(c, r * 1.22, Paint()..style = PaintingStyle.stroke..strokeWidth = selected ? 1.8 : hovered ? 1.1 : .35..color = accent.withValues(alpha: selected ? .95 : hovered ? .72 : .24));
    if (kind == GalaxyWorldKind.game || kind == GalaxyWorldKind.creation) { x.drawArc(Rect.fromCenter(center: c, width: r * 2.7, height: r * .72), -.25, math.pi * .72, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .035..color = accent.withValues(alpha: .30)); }
    if (selected) { x.drawCircle(c, r * .14, Paint()..shader = RadialGradient(colors: [Colors.white, accent.withValues(alpha: .3), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * .14))); }
    final tp = TextPainter(text: TextSpan(text: title, style: TextStyle(color: Colors.white.withValues(alpha: selected || hovered ? .95 : .58), fontSize: math.max(6.2, s.width * .052), letterSpacing: 1.45, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)), textDirection: TextDirection.ltr)..layout(maxWidth: s.width * 2.0);
    tp.paint(x, Offset(c.dx - tp.width / 2, s.height * .76));
  }
  @override bool shouldRepaint(covariant _WorldPainter o) => o.kind != kind || o.selected != selected || o.hovered != hovered || o.depth != depth || o.phase != phase;
}

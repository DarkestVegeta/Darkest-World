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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 160))..repeat();
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
    final compact = MediaQuery.sizeOf(context).width < 760, s = render;
    GalaxyWorld? current;
    for (final w in widget.worlds) { if (w.kind == selected) { current = w; break; } }
    return Scaffold(backgroundColor: const Color(0xFF010207), body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(fit: StackFit.expand, children: [
      CustomPaint(painter: _SpacePainter(clock.value)),
      CustomPaint(painter: _GalaxyPainter(clock.value, s.zoom, widget.worlds.length)),
      _Planets(worlds: widget.worlds, phase: clock.value, zoom: s.zoom, compact: compact, selected: selected, hovered: hovered, onSelect: _select, onOpen: _open, onHover: (w) => setState(() => hovered = w?.kind)),
      Positioned(left: compact ? 18 : 44, top: compact ? 18 : 38, child: const _Header()),
      Positioned(right: compact ? 18 : 44, top: compact ? 18 : 38, child: _Controls(reset: () { session.resetRenderState(compact: compact); _clear(); }, plus: () => session.updateRenderState(s.copyWith(zoom: (s.zoom + .08).clamp(.72, 1.55).toDouble())), minus: () => session.updateRenderState(s.copyWith(zoom: (s.zoom - .08).clamp(.72, 1.55).toDouble())))),
      if (current != null) Positioned(left: compact ? 18 : 44, right: compact ? 18 : 44, bottom: compact ? 18 : 32, child: _Card(world: current, index: widget.worlds.indexOf(current), count: widget.worlds.length, close: _clear)) else const Positioned(left: 0, right: 0, bottom: 28, child: Center(child: _Hint())),
    ])));
  }
}

class _Planets extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, zoom; final bool compact; final GalaxyWorldKind? selected, hovered; final ValueChanged<GalaxyWorld> onSelect, onOpen; final ValueChanged<GalaxyWorld?> onHover;
  const _Planets({required this.worlds, required this.phase, required this.zoom, required this.compact, required this.selected, required this.hovered, required this.onSelect, required this.onOpen, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, b) {
    final m = math.min(b.maxWidth, b.maxHeight), c = Offset(b.maxWidth * .5, b.maxHeight * .515), orbit = m * (compact ? .29 : .34) * zoom;
    final list = <Widget>[];
    for (var i = 0; i < worlds.length; i++) {
      final w = worlds[i], a = -math.pi / 2 + i * math.pi * 2 / worlds.length + phase * .055, rr = orbit * (.82 + (i % 3) * .065), p = Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr * .62);
      final d = m * (compact ? .135 : .15) * (selected == w.kind ? 1.2 : hovered == w.kind ? 1.08 : 1);
      list.add(Positioned(left: p.dx - d / 2, top: p.dy - d / 2, width: d, height: d, child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(w), onExit: (_) => onHover(null), child: GestureDetector(onTap: () => onSelect(w), onDoubleTap: () => onOpen(w), child: CustomPaint(painter: _Planet(w.kind, selected == w.kind, hovered == w.kind, phase))))));
    }
    return Stack(children: list);
  });
}

class _Header extends StatelessWidget { const _Header(); @override Widget build(BuildContext c) => IgnorePointer(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 6)), SizedBox(height: 7), Text('THE WORLDS / ATLAS', style: TextStyle(color: Color(0x78FFFFFF), fontSize: 7, letterSpacing: 3.3))])); }
class _Controls extends StatelessWidget { final VoidCallback reset, plus, minus; const _Controls({required this.reset, required this.plus, required this.minus}); @override Widget build(BuildContext c) => Row(children: [_B('+', plus), const SizedBox(width: 5), _B('−', minus), const SizedBox(width: 5), _B('RESET', reset)]); }
class _B extends StatelessWidget { final String t; final VoidCallback f; const _B(this.t, this.f); @override Widget build(BuildContext c) => InkWell(onTap: f, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0x65050810), border: Border.all(color: const Color(0x35FFFFFF))), child: Text(t, style: const TextStyle(color: Color(0xA8FFFFFF), fontSize: 6.5, letterSpacing: 1.5)))); }
class _Card extends StatelessWidget { final GalaxyWorld world; final int index, count; final VoidCallback close; const _Card({required this.world, required this.index, required this.count, required this.close}); @override Widget build(BuildContext c) => Container(padding: const EdgeInsets.fromLTRB(20, 15, 12, 15), decoration: BoxDecoration(color: const Color(0xE7070911), border: Border.all(color: const Color(0x42FFFFFF)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 35)]), child: Row(children: [Container(width: 3, height: 52, color: _accent(world.kind)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0x55FFFFFF), fontSize: 6, letterSpacing: 1.8)), const SizedBox(height: 5), Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 3)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x86FFFFFF), fontSize: 8))])), InkWell(onTap: close, child: const Padding(padding: EdgeInsets.all(8), child: Text('×', style: TextStyle(color: Color(0xA8FFFFFF), fontSize: 19))))])); }
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext c) => const Text('1× CLICK  FOCUS     2× CLICK  ENTER WORLD', style: TextStyle(color: Color(0x60FFFFFF), fontSize: 7, letterSpacing: 2)); }

class _SpacePainter extends CustomPainter {
  final double phase; const _SpacePainter(this.phase);
  @override void paint(Canvas x, Size s) {
    final r = Offset.zero & s; x.drawRect(r, Paint()..shader = const RadialGradient(center: Alignment(0, .02), radius: 1.1, colors: [Color(0xFF11101C), Color(0xFF050712), Color(0xFF010207)]).createShader(r));
    final rnd = math.Random(81291);
    for (var i = 0; i < 700; i++) { final p = Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height), a = .025 + rnd.nextDouble() * .14; x.drawCircle(p, .15 + rnd.nextDouble() * .9, Paint()..color = Colors.white.withValues(alpha: a * (.55 + .45 * math.sin(phase * 20 + i)))); }
    final c = Offset(s.width * .5, s.height * .515), haze = math.min(s.width, s.height) * .68; x.drawCircle(c, haze, Paint()..shader = RadialGradient(colors: [const Color(0xFF8C68AE).withValues(alpha: .09), const Color(0xFF463761).withValues(alpha: .025), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: haze)));
  }
  @override bool shouldRepaint(covariant _SpacePainter o) => o.phase != phase;
}

class _GalaxyPainter extends CustomPainter {
  final double phase, zoom; final int count; const _GalaxyPainter(this.phase, this.zoom, this.count);
  @override void paint(Canvas x, Size s) {
    final c = Offset(s.width * .5, s.height * .515), m = math.min(s.width, s.height), rx = m * .36 * zoom, ry = m * .225 * zoom;
    for (var i = 0; i < 5; i++) { final f = 1 - i * .14; x.drawOval(Rect.fromCenter(center: c, width: rx * 2 * f, height: ry * 2 * f), Paint()..style = PaintingStyle.stroke..strokeWidth = .45 + i * .12..color = const Color(0x15C0A7D2)); }
    for (var i = 0; i < count; i++) { final a = -math.pi / 2 + i * math.pi * 2 / count, p = Offset(c.dx + math.cos(a) * rx, c.dy + math.sin(a) * ry); x.drawLine(c, p, Paint()..color = const Color(0x0ABDA3D1)..strokeWidth = .5); }
    final sr = m * .047; x.drawCircle(c, sr * 4, Paint()..shader = RadialGradient(colors: [const Color(0xFFD7B7E2).withValues(alpha: .17), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: sr * 4))); x.drawCircle(c, sr, Paint()..shader = const RadialGradient(center: Alignment(-.4, -.45), colors: [Color(0xFFFFF8FF), Color(0xFFD8B8E0), Color(0xFF694875), Color(0xFF170D1E)]).createShader(Rect.fromCircle(center: c, radius: sr)));
    x.drawArc(Rect.fromCenter(center: c, width: rx * 1.7, height: ry * 1.7), phase * math.pi * 2, math.pi * .5, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = const Color(0x45D8C6E1));
  }
  @override bool shouldRepaint(covariant _GalaxyPainter o) => o.phase != phase || o.zoom != zoom || o.count != count;
}

class _Planet extends CustomPainter {
  final GalaxyWorldKind kind; final bool selected, hovered; final double phase; _Planet(this.kind, this.selected, this.hovered, this.phase);
  @override void paint(Canvas x, Size s) {
    final c = Offset(s.width / 2, s.height / 2), r = math.min(s.width, s.height) * .36, base = _base(kind), accent = _accent(kind), rnd = math.Random(_seed(kind));
    final halo = r * (selected ? 2.8 : hovered ? 2.25 : 1.7); x.drawCircle(c, halo, Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: selected ? .2 : .065), accent.withValues(alpha: .015), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: halo)));
    x.drawCircle(c, r * 1.12, Paint()..shader = RadialGradient(center: const Alignment(-.3, -.4), radius: 1, colors: [accent.withValues(alpha: .17), accent.withValues(alpha: .05), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * 1.12)));
    x.drawCircle(c, r, Paint()..shader = RadialGradient(center: const Alignment(-.44, -.48), radius: 1.02, colors: [Color.lerp(base, Colors.white, .45)!, Color.lerp(base, Colors.white, .18)!, base, Color.lerp(base, Colors.black, .58)!], stops: const [0, .23, .62, 1]).createShader(Rect.fromCircle(center: c, radius: r)));
    x.save(); x.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * .998)));
    switch (kind) { case GalaxyWorldKind.cinema: case GalaxyWorldKind.music: _gas(x, c, r, rnd); break; case GalaxyWorldKind.creation: _creation(x, c, r, rnd); break; case GalaxyWorldKind.archive: _ice(x, c, r, rnd); break; case GalaxyWorldKind.comingSoon: _desert(x, c, r); break; default: _rock(x, c, r, rnd); }
    _clouds(x, c, r, rnd); x.drawCircle(c, r, Paint()..shader = RadialGradient(center: const Alignment(.55, .45), radius: 1.08, colors: [Colors.transparent, Colors.black.withValues(alpha: .04), Colors.black.withValues(alpha: .43)]).createShader(Rect.fromCircle(center: c, radius: r))); x.restore();
    x.drawCircle(c, r * 1.005, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .035..color = accent.withValues(alpha: .18)); x.drawCircle(c, r * 1.015, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .012..color = Colors.white.withValues(alpha: .08)); if (selected) x.drawCircle(c, r * 1.14, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = accent.withValues(alpha: .52));
  }
  void _rock(Canvas x, Offset c, double r, math.Random q) { final land = _land(kind); for (var i = 0; i < 17; i++) { final cx = c.dx + (q.nextDouble() * 2 - 1) * r * .62, cy = c.dy + (q.nextDouble() * 2 - 1) * r * .68, w = r * (.1 + q.nextDouble() * .28), h = r * (.04 + q.nextDouble() * .1); final p = Path()..moveTo(cx - w, cy)..cubicTo(cx - w * .55, cy - h, cx - w * .15, cy - h * 1.2, cx, cy - h * .2)..cubicTo(cx + w * .5, cy - h, cx + w, cy + h * .2, cx + w, cy)..cubicTo(cx + w * .4, cy + h, cx - w * .5, cy + h * .8, cx - w, cy); x.drawPath(p, Paint()..color = land.withValues(alpha: .22 + q.nextDouble() * .28)); } for (var i = 0; i < 28; i++) { final p = Offset(c.dx + (q.nextDouble() * 2 - 1) * r * .8, c.dy + (q.nextDouble() * 2 - 1) * r * .8); x.drawCircle(p, r * (.004 + q.nextDouble() * .018), Paint()..color = Colors.black.withValues(alpha: .08 + q.nextDouble() * .1)); } }
  void _gas(Canvas x, Offset c, double r, math.Random q) { for (var i = -8; i <= 8; i++) { final y = c.dy + i * r * .085 + math.sin(i * 1.8 + phase * 6) * r * .018; x.drawOval(Rect.fromCenter(center: Offset(c.dx, y), width: r * 1.8, height: r * (.025 + q.nextDouble() * .05)), Paint()..color = (i.isEven ? Colors.white : Colors.black).withValues(alpha: i.isEven ? .06 : .08)); } for (var i = 0; i < 5; i++) { final p = Offset(c.dx - r * .45 + i * r * .22, c.dy + math.sin(i * 2 + phase * 4) * r * .28); x.drawOval(Rect.fromCenter(center: p, width: r * .22, height: r * .07), Paint()..color = Colors.white.withValues(alpha: .09)); } }
  void _creation(Canvas x, Offset c, double r, math.Random q) { for (var i = 0; i < 18; i++) { final a = i * math.pi * 2 / 18 + phase * .06, rr = r * (.2 + (i % 5) * .13); x.drawCircle(Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr * .8), r * (.025 + (i % 3) * .01), Paint()..color = const Color(0xFFC9A06A).withValues(alpha: .19)); } for (var i = 0; i < 7; i++) { final a = i * .92; x.drawLine(Offset(c.dx + math.cos(a) * r * .1, c.dy + math.sin(a) * r * .1), Offset(c.dx + math.cos(a + .3) * r * .7, c.dy + math.sin(a + .3) * r * .7), Paint()..color = Colors.white.withValues(alpha: .05)..strokeWidth = r * .012); } }
  void _ice(Canvas x, Offset c, double r, math.Random q) { for (var i = 0; i < 22; i++) { final a = q.nextDouble() * math.pi * 2, rr = q.nextDouble() * r * .8, p = Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr); x.drawOval(Rect.fromCenter(center: p, width: r * (.04 + q.nextDouble() * .13), height: r * (.012 + q.nextDouble() * .04)), Paint()..color = Colors.white.withValues(alpha: .09)); } }
  void _desert(Canvas x, Offset c, double r) { for (var i = 0; i < 11; i++) { final y = c.dy - r * .7 + i * r * .135; x.drawArc(Rect.fromCenter(center: Offset(c.dx, y), width: r * 1.55, height: r * .32), .05, math.pi * .8, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .022..color = const Color(0xFFB68B5C).withValues(alpha: .12)); } }
  void _clouds(Canvas x, Offset c, double r, math.Random q) { final p = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; for (var i = 0; i < 7; i++) { final y = c.dy - r * .6 + i * r * .19 + math.sin(i * 2.2 + phase * 6) * r * .025, w = r * (1 + q.nextDouble() * .4); p.strokeWidth = r * (.016 + q.nextDouble() * .015); p.color = Colors.white.withValues(alpha: .035 + q.nextDouble() * .055); x.drawArc(Rect.fromCenter(center: Offset(c.dx, y), width: w, height: r * .21), .2, math.pi * .78, false, p); } }
  @override bool shouldRepaint(covariant _Planet o) => o.kind != kind || o.selected != selected || o.hovered != hovered || o.phase != phase;
}

Color _base(GalaxyWorldKind k) => switch (k) { GalaxyWorldKind.vegeta => const Color(0xFF694B7B), GalaxyWorldKind.game => const Color(0xFF376372), GalaxyWorldKind.identity => const Color(0xFF5F6E75), GalaxyWorldKind.cinema => const Color(0xFF805E70), GalaxyWorldKind.creation => const Color(0xFF8A6949), GalaxyWorldKind.music => const Color(0xFF694B82), GalaxyWorldKind.family => const Color(0xFF527062), GalaxyWorldKind.archive => const Color(0xFF66889A), GalaxyWorldKind.comingSoon => const Color(0xFF82644B) };
Color _land(GalaxyWorldKind k) => switch (k) { GalaxyWorldKind.game => const Color(0xFF5E7E58), GalaxyWorldKind.identity => const Color(0xFF7A8C7C), GalaxyWorldKind.family => const Color(0xFF5D7F58), GalaxyWorldKind.vegeta => const Color(0xFF826C55), _ => const Color(0xFF796452) };
Color _accent(GalaxyWorldKind k) => switch (k) { GalaxyWorldKind.vegeta => const Color(0xFFC39ADA), GalaxyWorldKind.game => const Color(0xFF75AAC2), GalaxyWorldKind.identity => const Color(0xFF8EABB7), GalaxyWorldKind.cinema => const Color(0xFFC59BAF), GalaxyWorldKind.creation => const Color(0xFFC9A06A), GalaxyWorldKind.music => const Color(0xFFB68BD0), GalaxyWorldKind.family => const Color(0xFF7FA18E), GalaxyWorldKind.archive => const Color(0xFF9DC9DA), GalaxyWorldKind.comingSoon => const Color(0xFFB58C65) };
int _seed(GalaxyWorldKind k) => switch (k) { GalaxyWorldKind.vegeta => 1103, GalaxyWorldKind.game => 2207, GalaxyWorldKind.identity => 3311, GalaxyWorldKind.cinema => 4417, GalaxyWorldKind.creation => 5521, GalaxyWorldKind.music => 6637, GalaxyWorldKind.family => 7741, GalaxyWorldKind.archive => 8857, GalaxyWorldKind.comingSoon => 9967 };

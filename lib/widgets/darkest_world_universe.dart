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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 180))..repeat();
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
    return Scaffold(
      backgroundColor: const Color(0xFF010207),
      body: AnimatedBuilder(animation: clock, builder: (_, __) => Stack(fit: StackFit.expand, children: [
        CustomPaint(painter: _SpacePainter(clock.value)),
        CustomPaint(painter: _OrbitPainter(clock.value, s.zoom, widget.worlds.length)),
        _Planets(worlds: widget.worlds, phase: clock.value, zoom: s.zoom, compact: compact, selected: selected, hovered: hovered, onSelect: _select, onOpen: _open, onHover: (w) => setState(() => hovered = w?.kind)),
        CustomPaint(painter: _CinematicGradePainter()),
        Positioned(left: compact ? 18 : 44, top: compact ? 18 : 38, child: const _Header()),
        Positioned(right: compact ? 18 : 44, top: compact ? 18 : 38, child: _Controls(reset: () { session.resetRenderState(compact: compact); _clear(); }, plus: () => session.updateRenderState(s.copyWith(zoom: (s.zoom + .08).clamp(.72, 1.55).toDouble())), minus: () => session.updateRenderState(s.copyWith(zoom: (s.zoom - .08).clamp(.72, 1.55).toDouble())))),
        if (current != null) Positioned(left: compact ? 18 : 44, right: compact ? 18 : 44, bottom: compact ? 18 : 32, child: _Card(world: current, index: widget.worlds.indexOf(current), count: widget.worlds.length, close: _clear)) else const Positioned(left: 0, right: 0, bottom: 28, child: Center(child: _Hint())),
      ])),
    );
  }
}

class _Planets extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, zoom; final bool compact; final GalaxyWorldKind? selected, hovered; final ValueChanged<GalaxyWorld> onSelect, onOpen; final ValueChanged<GalaxyWorld?> onHover;
  const _Planets({required this.worlds, required this.phase, required this.zoom, required this.compact, required this.selected, required this.hovered, required this.onSelect, required this.onOpen, required this.onHover});
  @override Widget build(BuildContext context) => LayoutBuilder(builder: (_, b) {
    final m = math.min(b.maxWidth, b.maxHeight), center = Offset(b.maxWidth * .5, b.maxHeight * .515), orbit = m * (compact ? .285 : .335) * zoom;
    final children = <Widget>[];
    for (var i = 0; i < worlds.length; i++) {
      final w = worlds[i];
      final a = -math.pi / 2 + i * math.pi * 2 / worlds.length + phase * .035;
      final rr = orbit * (.82 + (i % 3) * .07);
      final p = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr * .58);
      final d = m * (compact ? .165 : .18) * (selected == w.kind ? 1.24 : hovered == w.kind ? 1.09 : 1);
      children.add(Positioned(left: p.dx - d / 2, top: p.dy - d / 2, width: d, height: d,
        child: MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => onHover(w), onExit: (_) => onHover(null),
          child: GestureDetector(onTap: () => onSelect(w), onDoubleTap: () => onOpen(w), child: CustomPaint(painter: _Planet(w.kind, selected == w.kind, hovered == w.kind, phase))))));
    }
    return Stack(children: children);
  });
}

class _Header extends StatelessWidget { const _Header(); @override Widget build(BuildContext c) => IgnorePointer(child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 15, letterSpacing: 6)), SizedBox(height: 7), Text('THE WORLDS / CINEMATIC ATLAS', style: TextStyle(color: Color(0x78FFFFFF), fontSize: 7, letterSpacing: 2.8))])); }
class _Controls extends StatelessWidget { final VoidCallback reset, plus, minus; const _Controls({required this.reset, required this.plus, required this.minus}); @override Widget build(BuildContext c) => Row(children: [_B('+', plus), const SizedBox(width: 5), _B('−', minus), const SizedBox(width: 5), _B('RESET', reset)]); }
class _B extends StatelessWidget { final String t; final VoidCallback f; const _B(this.t, this.f); @override Widget build(BuildContext c) => InkWell(onTap: f, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0x65050810), border: Border.all(color: const Color(0x35FFFFFF))), child: Text(t, style: const TextStyle(color: Color(0xA8FFFFFF), fontSize: 6.5, letterSpacing: 1.5)))); }
class _Card extends StatelessWidget { final GalaxyWorld world; final int index, count; final VoidCallback close; const _Card({required this.world, required this.index, required this.count, required this.close}); @override Widget build(BuildContext c) => Container(padding: const EdgeInsets.fromLTRB(20, 15, 12, 15), decoration: BoxDecoration(color: const Color(0xE7070911), border: Border.all(color: const Color(0x42FFFFFF)), boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 35)]), child: Row(children: [Container(width: 3, height: 52, color: _accent(world.kind)), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${(index + 1).toString().padLeft(2, '0')} / ${count.toString().padLeft(2, '0')}', style: const TextStyle(color: Color(0x55FFFFFF), fontSize: 6, letterSpacing: 1.8)), const SizedBox(height: 5), Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 3)), const SizedBox(height: 5), Text(world.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0x86FFFFFF), fontSize: 8))])), InkWell(onTap: close, child: const Padding(padding: EdgeInsets.all(8), child: Text('×', style: TextStyle(color: Color(0xA8FFFFFF), fontSize: 19))))])); }
class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext c) => const Text('1× CLICK  FOCUS     2× CLICK  ENTER WORLD', style: TextStyle(color: Color(0x60FFFFFF), fontSize: 7, letterSpacing: 2)); }

class _SpacePainter extends CustomPainter {
  final double phase; const _SpacePainter(this.phase);
  @override void paint(Canvas x, Size s) {
    final rect = Offset.zero & s;
    x.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, .03), radius: 1.08, colors: [Color(0xFF151322), Color(0xFF060813), Color(0xFF010207)]).createShader(rect));
    final rnd = math.Random(81291);
    for (var i = 0; i < 520; i++) {
      final p = Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height);
      final twinkle = .55 + .45 * math.sin(phase * 14 + i * .73);
      x.drawCircle(p, .18 + rnd.nextDouble() * .75, Paint()..color = Colors.white.withValues(alpha: (.018 + rnd.nextDouble() * .105) * twinkle));
    }
    final c = Offset(s.width * .5, s.height * .515), h = math.min(s.width, s.height) * .72;
    x.drawCircle(c, h, Paint()..shader = RadialGradient(colors: [const Color(0xFF9072B8).withValues(alpha: .075), const Color(0xFF443452).withValues(alpha: .022), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: h)));
    final band = Rect.fromCenter(center: Offset(c.dx, c.dy + h * .18), width: s.width * .92, height: h * .18);
    x.drawOval(band, Paint()..shader = RadialGradient(colors: [const Color(0xFFB69AD2).withValues(alpha: .025), Colors.transparent]).createShader(band));
  }
  @override bool shouldRepaint(covariant _SpacePainter o) => o.phase != phase;
}

class _OrbitPainter extends CustomPainter {
  final double phase, zoom; final int count; const _OrbitPainter(this.phase, this.zoom, this.count);
  @override void paint(Canvas x, Size s) {
    final c = Offset(s.width * .5, s.height * .515), m = math.min(s.width, s.height), rx = m * .35 * zoom, ry = m * .205 * zoom;
    for (var i = 0; i < 4; i++) {
      final f = 1 - i * .14;
      x.drawOval(Rect.fromCenter(center: c, width: rx * 2 * f, height: ry * 2 * f), Paint()..style = PaintingStyle.stroke..strokeWidth = .45 + i * .1..color = const Color(0x13D1B8E4));
    }
    final starR = m * .045;
    x.drawCircle(c, starR * 4.6, Paint()..shader = RadialGradient(colors: [const Color(0xFFDABFE8).withValues(alpha: .15), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: starR * 4.6)));
    x.drawCircle(c, starR, Paint()..shader = const RadialGradient(center: Alignment(-.35, -.5), colors: [Color(0xFFFFFFFF), Color(0xFFE6CFF0), Color(0xFF765181), Color(0xFF160C1C)]).createShader(Rect.fromCircle(center: c, radius: starR)));
    final a = phase * math.pi * 2;
    x.drawArc(Rect.fromCenter(center: c, width: rx * 1.8, height: ry * 1.8), a, math.pi * .35, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x38E2D4E9));
  }
  @override bool shouldRepaint(covariant _OrbitPainter o) => o.phase != phase || o.zoom != zoom || o.count != count;
}

class _CinematicGradePainter extends CustomPainter {
  @override void paint(Canvas x, Size s) {
    final r = Offset.zero & s;
    x.drawRect(r, Paint()..shader = RadialGradient(center: const Alignment(0, 0), radius: 1.05, colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: .32)]).createShader(r));
    x.drawRect(r, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withValues(alpha: .18), Colors.transparent, Colors.black.withValues(alpha: .18)]).createShader(r));
  }
  @override bool shouldRepaint(covariant _CinematicGradePainter oldDelegate) => false;
}

class _Planet extends CustomPainter {
  final GalaxyWorldKind kind; final bool selected, hovered; final double phase;
  _Planet(this.kind, this.selected, this.hovered, this.phase);
  @override void paint(Canvas x, Size s) {
    final c = Offset(s.width / 2, s.height / 2), r = math.min(s.width, s.height) * .405;
    final base = _base(kind), accent = _accent(kind), q = math.Random(_seed(kind));
    final lightA = -1.05 + math.sin(phase * math.pi * 2) * .10;
    final light = Offset(math.cos(lightA), math.sin(lightA));
    final haloR = r * (selected ? 2.65 : hovered ? 2.15 : 1.62);
    x.drawCircle(c, haloR, Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: selected ? .16 : .052), accent.withValues(alpha: .012), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: haloR)));
    x.drawCircle(c, r * 1.10, Paint()..shader = RadialGradient(center: Alignment(light.dx, light.dy), radius: 1, colors: [accent.withValues(alpha: .22), accent.withValues(alpha: .07), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * 1.10)));
    x.drawCircle(c, r, Paint()..shader = RadialGradient(center: Alignment(light.dx * .68, light.dy * .68), radius: 1.02, colors: [Color.lerp(base, Colors.white, .42)!, Color.lerp(base, Colors.white, .17)!, base, Color.lerp(base, Colors.black, .62)!], stops: const [.0, .25, .62, 1]).createShader(Rect.fromCircle(center: c, radius: r)));
    x.save(); x.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * .998)));
    switch (kind) {
      case GalaxyWorldKind.cinema: case GalaxyWorldKind.music: _gas(x, c, r, q); break;
      case GalaxyWorldKind.creation: _creation(x, c, r, q); break;
      case GalaxyWorldKind.archive: _ice(x, c, r, q); break;
      case GalaxyWorldKind.comingSoon: _desert(x, c, r, q); break;
      default: _rock(x, c, r, q);
    }
    _clouds(x, c, r, q);
    final terminator = Rect.fromCenter(center: Offset(c.dx - light.dx * r * .46, c.dy - light.dy * r * .46), width: r * 2.1, height: r * 2.1);
    x.drawOval(terminator, Paint()..shader = RadialGradient(center: Alignment(-light.dx, -light.dy), radius: .9, colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: .62)]).createShader(terminator));
    x.restore();
    x.drawCircle(c, r * 1.002, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .028..color = accent.withValues(alpha: .22));
    x.drawCircle(c, r * 1.018, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .012..color = Colors.white.withValues(alpha: .07));
    if (selected) x.drawCircle(c, r * 1.14, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.1..color = accent.withValues(alpha: .55));
  }

  void _rock(Canvas x, Offset c, double r, math.Random q) {
    final land = _land(kind);
    for (var i = 0; i < 15; i++) {
      final cx = c.dx + (q.nextDouble() * 2 - 1) * r * .58, cy = c.dy + (q.nextDouble() * 2 - 1) * r * .62;
      final w = r * (.11 + q.nextDouble() * .27), h = r * (.05 + q.nextDouble() * .11);
      final p = Path()..moveTo(cx - w, cy)..cubicTo(cx - w * .7, cy - h, cx - w * .25, cy - h * 1.4, cx, cy - h * .2)..cubicTo(cx + w * .35, cy - h, cx + w, cy + h * .15, cx + w, cy)..cubicTo(cx + w * .45, cy + h, cx - w * .45, cy + h, cx - w, cy);
      x.drawPath(p, Paint()..color = land.withValues(alpha: .18 + q.nextDouble() * .30));
      x.drawPath(p, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .008..color = Colors.white.withValues(alpha: .035));
    }
    for (var i = 0; i < 34; i++) {
      final p = Offset(c.dx + (q.nextDouble() * 2 - 1) * r * .82, c.dy + (q.nextDouble() * 2 - 1) * r * .82);
      final rr = r * (.004 + q.nextDouble() * .018);
      x.drawCircle(p, rr, Paint()..color = Colors.black.withValues(alpha: .07 + q.nextDouble() * .10));
      if (i % 4 == 0) x.drawCircle(Offset(p.dx - rr * .5, p.dy - rr * .5), rr * .45, Paint()..color = Colors.white.withValues(alpha: .045));
    }
  }

  void _gas(Canvas x, Offset c, double r, math.Random q) {
    for (var i = -10; i <= 10; i++) {
      final y = c.dy + i * r * .072 + math.sin(i * 1.7 + phase * 4) * r * .018;
      final h = r * (.018 + q.nextDouble() * .055);
      x.drawOval(Rect.fromCenter(center: Offset(c.dx, y), width: r * (1.55 + q.nextDouble() * .45), height: h), Paint()..color = (i.isEven ? Colors.white : Colors.black).withValues(alpha: i.isEven ? .055 : .075));
    }
    for (var i = 0; i < 7; i++) {
      final p = Offset(c.dx - r * .55 + i * r * .18, c.dy + math.sin(i * 1.8 + phase * 3) * r * .3);
      x.drawOval(Rect.fromCenter(center: p, width: r * (.18 + q.nextDouble() * .18), height: r * (.035 + q.nextDouble() * .05)), Paint()..color = Colors.white.withValues(alpha: .055));
    }
  }

  void _creation(Canvas x, Offset c, double r, math.Random q) {
    for (var i = 0; i < 20; i++) {
      final a = i * math.pi * 2 / 20 + phase * .05, rr = r * (.18 + (i % 6) * .12);
      final p = Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr * .82);
      x.drawCircle(p, r * (.018 + (i % 3) * .008), Paint()..color = const Color(0xFFD3AE72).withValues(alpha: .17));
      if (i > 0) x.drawLine(p, Offset(c.dx + math.cos(a - .55) * rr * .9, c.dy + math.sin(a - .55) * rr * .75), Paint()..color = const Color(0xFFD3AE72).withValues(alpha: .055)..strokeWidth = r * .009);
    }
  }

  void _ice(Canvas x, Offset c, double r, math.Random q) {
    for (var i = 0; i < 25; i++) {
      final a = q.nextDouble() * math.pi * 2, rr = q.nextDouble() * r * .82, p = Offset(c.dx + math.cos(a) * rr, c.dy + math.sin(a) * rr);
      x.drawOval(Rect.fromCenter(center: p, width: r * (.025 + q.nextDouble() * .12), height: r * (.008 + q.nextDouble() * .035)), Paint()..color = Colors.white.withValues(alpha: .055 + q.nextDouble() * .08));
    }
  }

  void _desert(Canvas x, Offset c, double r, math.Random q) {
    for (var i = 0; i < 12; i++) {
      final y = c.dy - r * .7 + i * r * .13;
      x.drawArc(Rect.fromCenter(center: Offset(c.dx + math.sin(i * .7) * r * .18, y), width: r * 1.55, height: r * .3), .05, math.pi * .82, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .018..color = const Color(0xFFC29A68).withValues(alpha: .09 + q.nextDouble() * .05));
    }
  }

  void _clouds(Canvas x, Offset c, double r, math.Random q) {
    final p = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    for (var i = 0; i < 8; i++) {
      final y = c.dy - r * .58 + i * r * .165 + math.sin(i * 2.1 + phase * 5) * r * .025;
      p.strokeWidth = r * (.012 + q.nextDouble() * .018);
      p.color = Colors.white.withValues(alpha: .025 + q.nextDouble() * .055);
      x.drawArc(Rect.fromCenter(center: Offset(c.dx, y), width: r * (1.0 + q.nextDouble() * .5), height: r * .18), .15, math.pi * .82, false, p);
    }
  }

  @override bool shouldRepaint(covariant _Planet o) => o.kind != kind || o.selected != selected || o.hovered != hovered || o.phase != phase;
}

Color _base(GalaxyWorldKind k) => switch (k) {
  GalaxyWorldKind.vegeta => const Color(0xFF63456F), GalaxyWorldKind.game => const Color(0xFF365F68), GalaxyWorldKind.identity => const Color(0xFF5C6B71),
  GalaxyWorldKind.cinema => const Color(0xFF795669), GalaxyWorldKind.creation => const Color(0xFF856345), GalaxyWorldKind.music => const Color(0xFF5F4675),
  GalaxyWorldKind.family => const Color(0xFF4F6C5B), GalaxyWorldKind.archive => const Color(0xFF607F8E), GalaxyWorldKind.comingSoon => const Color(0xFF7B6048),
};
Color _land(GalaxyWorldKind k) => switch (k) {
  GalaxyWorldKind.game => const Color(0xFF64845D), GalaxyWorldKind.identity => const Color(0xFF7C8B7D), GalaxyWorldKind.family => const Color(0xFF58785B),
  GalaxyWorldKind.vegeta => const Color(0xFF806850), _ => const Color(0xFF75604E),
};
Color _accent(GalaxyWorldKind k) => switch (k) {
  GalaxyWorldKind.vegeta => const Color(0xFFC49AD9), GalaxyWorldKind.game => const Color(0xFF76B0C4), GalaxyWorldKind.identity => const Color(0xFF8CAAB4),
  GalaxyWorldKind.cinema => const Color(0xFFC49AAA), GalaxyWorldKind.creation => const Color(0xFFC7A06B), GalaxyWorldKind.music => const Color(0xFFB38ACD),
  GalaxyWorldKind.family => const Color(0xFF7FA08C), GalaxyWorldKind.archive => const Color(0xFF9BC8D8), GalaxyWorldKind.comingSoon => const Color(0xFFB38B64),
};
int _seed(GalaxyWorldKind k) => switch (k) {
  GalaxyWorldKind.vegeta => 1103, GalaxyWorldKind.game => 2207, GalaxyWorldKind.identity => 3311, GalaxyWorldKind.cinema => 4417,
  GalaxyWorldKind.creation => 5521, GalaxyWorldKind.music => 6637, GalaxyWorldKind.family => 7741, GalaxyWorldKind.archive => 8857, GalaxyWorldKind.comingSoon => 9967,
};

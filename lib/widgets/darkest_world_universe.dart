import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GalaxyWorldKind { vegeta, game, identity, cinema, creation, music, family, archive, comingSoon }

class GalaxyWorld {
  final GalaxyWorldKind kind;
  final String title, description;
  const GalaxyWorld({required this.kind, required this.title, required this.description});
}

class DarkestWorldUniverse extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverse({super.key, required this.worlds, this.onWorldTap});
  @override State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> with SingleTickerProviderStateMixin {
  GalaxyWorldKind? selected;
  double orbitOffset = 0, zoom = 1;
  Offset? dragStart;
  bool mapMode = false, labels = true;
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 58))..repeat();
  @override void dispose() { clock.dispose(); super.dispose(); }
  void _select(GalaxyWorld w) => setState(() => selected = selected == w.kind ? null : w.kind);
  void _reset() => setState(() { orbitOffset = 0; zoom = 1; selected = null; });

  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context), compact = size.width < 760;
    GalaxyWorld? current;
    for (final w in widget.worlds) { if (w.kind == selected) { current = w; break; } }
    return Scaffold(
      backgroundColor: const Color(0xFF010106),
      body: GestureDetector(
        onScaleStart: (d) => dragStart = d.focalPoint,
        onScaleUpdate: (d) {
          if (d.pointerCount > 1) setState(() => zoom = (zoom * d.scale).clamp(.62, 1.58));
          else if (dragStart != null) { final dx = d.focalPoint.dx - dragStart!.dx; setState(() => orbitOffset += dx / math.max(180, size.width)); dragStart = d.focalPoint; }
        },
        onScaleEnd: (_) => dragStart = null,
        child: AnimatedBuilder(
          animation: clock,
          builder: (_, __) => Stack(fit: StackFit.expand, children: [
            CustomPaint(painter: _GalaxyField(clock.value, orbitOffset, selected != null, mapMode)),
            Transform.scale(scale: zoom, child: CustomPaint(painter: _SystemArchitecture(clock.value, orbitOffset, mapMode))),
            _PlanetRing(worlds: widget.worlds, phase: clock.value, orbit: orbitOffset, selected: selected, labels: labels, compact: compact, onTap: _select),
            Positioned(left: compact ? 16 : 34, top: compact ? 16 : 28, child: _Header(mapMode: mapMode, compact: compact)),
            Positioned(right: compact ? 12 : 30, top: compact ? 16 : 28, child: _Controls(zoom: zoom, mapMode: mapMode, labels: labels, onIn: () => setState(() => zoom = (zoom + .1).clamp(.62, 1.58)), onOut: () => setState(() => zoom = (zoom - .1).clamp(.62, 1.58)), onMode: () => setState(() => mapMode = !mapMode), onLabels: () => setState(() => labels = !labels), onReset: _reset)),
            Positioned(left: compact ? 12 : 30, top: compact ? 82 : 92, child: _SystemReadout(phase: clock.value, mapMode: mapMode, selected: current, compact: compact)),
            if (current != null) Positioned(left: compact ? 12 : 30, right: compact ? 12 : 30, bottom: compact ? 12 : 28, child: _WorldPanel(world: current!, compact: compact, phase: clock.value, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!)))
            else Positioned(left: 0, right: 0, bottom: compact ? 16 : 28, child: const Center(child: _Hint())),
          ]),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool mapMode, compact;
  const _Header({required this.mapMode, required this.compact});
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300)),
    const SizedBox(height: 7), Text(mapMode ? 'GALAXY / SYSTEM MAP' : 'GALAXY / DEEP ORBIT', style: const TextStyle(color: Colors.white38, fontSize: 7, letterSpacing: 2.6)),
    const SizedBox(height: 5), Text(compact ? '09 WORLD NODES' : '09 WORLD NODES  •  PROCEDURAL STAR SYSTEM', style: const TextStyle(color: Colors.white24, fontSize: 6, letterSpacing: 1.6)),
  ]);
}

class _Controls extends StatelessWidget {
  final double zoom; final bool mapMode, labels;
  final VoidCallback onIn, onOut, onMode, onLabels, onReset;
  const _Controls({required this.zoom, required this.mapMode, required this.labels, required this.onIn, required this.onOut, required this.onMode, required this.onLabels, required this.onReset});
  Widget b(IconData icon, VoidCallback f, {bool active = false}) => InkWell(onTap: f, borderRadius: BorderRadius.circular(8), child: Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: active ? const Color(0x22100D1C) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 12, color: active ? Colors.white70 : Colors.white38)));
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: const Color(0xD9090911), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0x223F3A55))), child: Row(mainAxisSize: MainAxisSize.min, children: [b(Icons.remove, onOut), Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Text('${(zoom * 100).round()}%', style: const TextStyle(color: Colors.white54, fontSize: 7))), b(Icons.add, onIn), const SizedBox(width: 3), b(Icons.grid_view_rounded, onMode, active: mapMode), b(labels ? Icons.title : Icons.title_outlined, onLabels, active: labels), b(Icons.refresh, onReset)]));
}

class _PlanetRing extends StatelessWidget {
  final List<GalaxyWorld> worlds; final double phase, orbit; final GalaxyWorldKind? selected; final bool labels, compact; final ValueChanged<GalaxyWorld> onTap;
  const _PlanetRing({required this.worlds, required this.phase, required this.orbit, required this.selected, required this.labels, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context), center = Offset(s.width * .5, s.height * .52), rx = math.min(s.width, s.height) * (compact ? .34 : .39), ry = math.min(s.width, s.height) * (compact ? .25 : .30);
    final children = <Widget>[];
    for (var i = 0; i < worlds.length; i++) {
      final w = worlds[i], a = -math.pi / 2 + i * math.pi * 2 / math.max(1, worlds.length) + phase * .13 + orbit;
      final depth = .48 + .52 * ((math.sin(a) + 1) / 2), p = Offset(center.dx + math.cos(a) * rx, center.dy + math.sin(a) * ry);
      final base = compact ? 72.0 : 104.0, size = selected == w.kind ? base * 1.52 : base * (.70 + depth * .38), opacity = selected == null || selected == w.kind ? 1 : .13;
      children.add(Positioned(left: p.dx - size / 2, top: p.dy - size / 2, width: size, child: Opacity(opacity: opacity, child: GestureDetector(onTap: () => onTap(w), child: Column(children: [CustomPaint(size: Size.square(size), painter: _PlanetPainter(seed: i * 31 + 17, phase: phase, active: selected == w.kind, depth: depth, kind: w.kind)), if (labels) Padding(padding: const EdgeInsets.only(top: 5), child: Text(w.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: selected == w.kind ? .9 : .42), fontSize: selected == w.kind ? 9 : 6.5, letterSpacing: 1.7)))]))));
    }
    return Stack(fit: StackFit.expand, children: children);
  }
}

class _PlanetPainter extends CustomPainter {
  final int seed; final double phase, depth; final bool active; final GalaxyWorldKind kind;
  const _PlanetPainter({required this.seed, required this.phase, required this.active, required this.depth, required this.kind});
  @override void paint(Canvas c, Size s) {
    final r = math.Random(seed * 773), center = Offset(s.width * .47, s.height * .45), rad = s.shortestSide * .44;
    final accent = kind == GalaxyWorldKind.game ? const Color(0xFF78849A) : kind == GalaxyWorldKind.vegeta ? const Color(0xFF8E6FAA) : const Color(0xFF6D777B);
    final sphere = Rect.fromCircle(center: center, radius: rad);
    c.drawCircle(center, rad * 1.25, Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: active ? .22 : .10), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: rad * 1.28)));
    c.drawCircle(center + Offset(rad * .035, rad * .04), rad * 1.015, Paint()..shader = RadialGradient(center: const Alignment(-.55, -.58), radius: 1.12, colors: [const Color(0xFFE3DED2), const Color(0xFF9C9D98), const Color(0xFF555A59), const Color(0xFF171A20), const Color(0xFF020308)], stops: const [.0, .16, .39, .72, 1]).createShader(sphere));
    c.save(); c.clipPath(Path()..addOval(sphere));
    _terrain(c, center, rad, r, accent);
    _surface(c, center, rad, r);
    _clouds(c, center, rad, phase);
    c.restore();
    final terminator = center + Offset(rad * .46, rad * .08);
    c.drawCircle(terminator, rad * .96, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .78)]).createShader(Rect.fromCircle(center: terminator, radius: rad * .96)));
    c.drawArc(Rect.fromCircle(center: center, radius: rad * 1.015), math.pi * .61, math.pi * .82, false, Paint()..style = PaintingStyle.stroke..strokeWidth = rad * .018..color = Colors.white.withValues(alpha: active ? .34 : .18));
    if (seed % 3 != 1) _moon(c, center, rad, phase, seed);
    if (active) c.drawCircle(center, rad * 1.13, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = Colors.white.withValues(alpha: .24 + depth * .12));
  }
  void _terrain(Canvas c, Offset center, double rad, math.Random r, Color accent) {
    final fills = [accent.withValues(alpha: .30), const Color(0xFF9C886D).withValues(alpha: .22), const Color(0xFF53675E).withValues(alpha: .19), const Color(0xFFB2A487).withValues(alpha: .13)];
    for (var k = 0; k < 9; k++) {
      final a = k * 2.13 + seed * .13, cc = center + Offset(math.cos(a) * rad * (.26 + (k % 3) * .11), math.sin(a) * rad * (.27 + (k % 2) * .10));
      final w = rad * (.32 + r.nextDouble() * .34), h = rad * (.14 + r.nextDouble() * .19), rot = a * .37;
      final outer = _blob(cc, w, h, rot, seed + k * 13, 48);
      c.drawPath(outer, Paint()..color = fills[k % fills.length]);
      for (var q = 1; q <= 6; q++) c.drawPath(_blob(cc, w * (1 - q * .105), h * (1 - q * .105), rot, seed + k * 13 + q, 40), Paint()..style = PaintingStyle.stroke..strokeWidth = rad * .006..color = Colors.white.withValues(alpha: .010 + (7 - q) * .004));
      for (var ridge = 0; ridge < 3; ridge++) { final yy = cc.dy + (ridge - 1) * h * .23; c.drawArc(Rect.fromCenter(center: Offset(cc.dx, yy), width: w * 1.2, height: h * .55), .15 + rot, 2.5, false, Paint()..style = PaintingStyle.stroke..strokeWidth = rad * .009..color = Colors.black.withValues(alpha: .08)); }
    }
    for (var i = 0; i < 180; i++) { final x = center.dx + (r.nextDouble() * 2 - 1) * rad, y = center.dy + (r.nextDouble() * 2 - 1) * rad; if ((Offset(x, y) - center).distance < rad) c.drawCircle(Offset(x, y), .18 + r.nextDouble() * .85, Paint()..color = Colors.white.withValues(alpha: .006 + r.nextDouble() * .018)); }
  }
  void _surface(Canvas c, Offset center, double rad, math.Random r) {
    for (var i = 0; i < 28; i++) { final a = r.nextDouble() * math.pi * 2, rr = rad * (.15 + r.nextDouble() * .72), p = center + Offset(math.cos(a) * rr, math.sin(a) * rr); c.drawCircle(p, rad * (.004 + r.nextDouble() * .012), Paint()..color = const Color(0x334B5150)); }
    for (var k = 0; k < 5; k++) { final y = center.dy - rad * .58 + k * rad * .29 + math.sin(phase * math.pi * 2 + k + seed) * rad * .025; c.drawArc(Rect.fromCenter(center: Offset(center.dx, y), width: rad * 1.72, height: rad * .22), .08, 2.95, false, Paint()..style = PaintingStyle.stroke..strokeWidth = rad * .025..color = Colors.white.withValues(alpha: .025)); }
  }
  void _clouds(Canvas c, Offset center, double rad, double phase) { for (var i = 0; i < 7; i++) { final y = center.dy - rad * .72 + i * rad * .23 + math.sin(phase * math.pi * 2 * (i.isEven ? 1 : -.7) + seed) * rad * .035; c.drawArc(Rect.fromCenter(center: Offset(center.dx, y), width: rad * 1.9, height: rad * .16), .03, math.pi * .92, false, Paint()..style = PaintingStyle.stroke..strokeWidth = rad * .032..color = Colors.white.withValues(alpha: .028)); } }
  void _moon(Canvas c, Offset center, double rad, double phase, int n) { final a = phase * math.pi * 2 + n, p = center + Offset(math.cos(a) * rad * 1.72, math.sin(a) * rad * .48); c.drawCircle(p, rad * .032, Paint()..color = Colors.white.withValues(alpha: .16)); c.drawCircle(p + Offset(rad * .012, rad * .008), rad * .018, Paint()..color = Colors.black.withValues(alpha: .16)); }
  Path _blob(Offset c, double w, double h, double rot, int local, int points) { final q = math.Random(local * 19 + 3), pts = <Offset>[]; for (var i = 0; i < points; i++) { final a = i * math.pi * 2 / points, n = .82 + math.sin(a * 2.1 + local) * .10 + math.sin(a * 4.7 + local * .3) * .06 + q.nextDouble() * .08, x = math.cos(a) * w * .5 * n, y = math.sin(a) * h * .5 * n; pts.add(Offset(c.dx + x * math.cos(rot) - y * math.sin(rot), c.dy + x * math.sin(rot) + y * math.cos(rot))); } final p = Path()..moveTo(pts[0].dx, pts[0].dy); for (var i = 0; i < pts.length; i++) { final a = pts[i], b = pts[(i + 1) % pts.length]; p.quadraticBezierTo(a.dx, a.dy, (a.dx + b.dx) / 2, (a.dy + b.dy) / 2); } return p..close(); }
  @override bool shouldRepaint(covariant _PlanetPainter old) => old.phase != phase || old.active != active || old.depth != depth;
}

class _SystemArchitecture extends CustomPainter {
  final double phase, orbit; final bool mapMode;
  const _SystemArchitecture(this.phase, this.orbit, this.mapMode);
  @override void paint(Canvas c, Size s) {
    final center = Offset(s.width * .5, s.height * .52), min = math.min(s.width, s.height);
    c.drawCircle(center, min * .075, Paint()..shader = RadialGradient(colors: [const Color(0xCDE8E0D0), const Color(0x44766A86), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: min * .075)));
    c.drawCircle(center, min * .020, Paint()..color = const Color(0xE8EEE7D8));
    for (var i = 0; i < 12; i++) { final wobble = math.sin(phase * math.pi * 2 + i) * .006; final rect = Rect.fromCenter(center: center, width: min * (.20 + i * .073 + wobble), height: min * (.13 + i * .054)); c.drawOval(rect, Paint()..style = PaintingStyle.stroke..strokeWidth = i < 2 ? 1.0 : .32..color = Color.fromRGBO(143, 130, 166, mapMode ? .15 : .075)); }
    for (var i = 0; i < 36; i++) { final a = phase * math.pi * 2 * (i.isEven ? .012 : -.009) + i * .91 + orbit, rr = min * (.12 + (i % 10) * .073); final p = Offset(center.dx + math.cos(a) * rr, center.dy + math.sin(a) * rr * .63); c.drawCircle(p, .7 + (i % 4) * .35, Paint()..color = const Color(0x3CACA1BA)); }
    for (var i = 0; i < 8; i++) { final a = phase * math.pi * 2 * (i.isEven ? .018 : -.014) + i * .8; final p1 = Offset(center.dx + math.cos(a) * min * .16, center.dy + math.sin(a) * min * .10); final p2 = Offset(center.dx + math.cos(a + .42) * min * .44, center.dy + math.sin(a + .42) * min * .28); final path = Path()..moveTo(p1.dx, p1.dy)..quadraticBezierTo(center.dx + math.cos(a + .2) * min * .27, center.dy + math.sin(a + .2) * min * .16, p2.dx, p2.dy); c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = const Color(0x1F9A8DB0)); }
  }
  @override bool shouldRepaint(covariant _SystemArchitecture old) => old.phase != phase || old.orbit != orbit || old.mapMode != mapMode;
}

class _GalaxyField extends CustomPainter {
  final double phase, orbit; final bool focused, mapMode;
  const _GalaxyField(this.phase, this.orbit, this.focused, this.mapMode);
  @override void paint(Canvas c, Size s) {
    final rect = Offset.zero & s, center = Offset(s.width * .5, s.height * .5);
    c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.10), radius: 1.22, colors: [Color(0xFF342B47), Color(0xFF0B0A13), Color(0xFF010104)]).createShader(rect));
    final rnd = math.Random(8127);
    for (var i = 0; i < 1120; i++) { final layer = i % 6, speed = .0015 + layer * .0038, x = (rnd.nextDouble() * s.width + phase * s.width * speed + orbit * s.width * (.05 + layer * .018)) % s.width, y = rnd.nextDouble() * s.height; final a = .009 + layer * .007 + .016 * (.5 + .5 * math.sin(phase * math.pi * 2 + i)); c.drawCircle(Offset(x, y), .08 + rnd.nextDouble() * (layer > 3 ? .9 : .55), Paint()..color = Colors.white.withValues(alpha: a)); }
    for (var k = 0; k < 7; k++) { final p = Offset(s.width * (.15 + k * .13), s.height * (.18 + math.sin(k * 1.7) * .12)); c.drawCircle(p, s.shortestSide * (.16 + k * .012), Paint()..shader = RadialGradient(colors: [Color.fromRGBO(106, 91, 142, focused ? .045 : .03), Colors.transparent]).createShader(Rect.fromCircle(center: p, radius: s.shortestSide * .17))); }
    for (var i = 0; i < 18; i++) { final a = phase * math.pi * 2 * (i.isEven ? .008 : -.006) + i * .37 + orbit * .25, rx = s.width * (.20 + i * .035), ry = s.height * (.13 + i * .022); final p = Offset(center.dx + math.cos(a) * rx, center.dy + math.sin(a) * ry); c.drawCircle(p, 1 + (i % 5) * .55, Paint()..color = const Color(0x248B7FA3)); }
    c.drawRect(rect, Paint()..shader = const RadialGradient(colors: [Colors.transparent, Color(0x68000000)]).createShader(Rect.fromCenter(center: center, width: s.width * 1.12, height: s.height * 1.12)));
  }
  @override bool shouldRepaint(covariant _GalaxyField old) => old.phase != phase || old.orbit != orbit || old.focused != focused || old.mapMode != mapMode;
}

class _SystemReadout extends StatelessWidget {
  final double phase; final bool mapMode, compact; final GalaxyWorld? selected;
  const _SystemReadout({required this.phase, required this.mapMode, required this.selected, required this.compact});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: const Color(0x9907070D), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0x183F3A55))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.radio_button_checked, size: 8, color: Color(0x887F70B0)), const SizedBox(width: 6), Text(selected == null ? 'SYSTEM STABLE' : 'NODE LOCK  •  ${selected!.title.toUpperCase()}', style: const TextStyle(color: Colors.white38, fontSize: 6.2, letterSpacing: 1.3)), if (!compact) ...[const SizedBox(width: 12), Text('${(phase * 360).round() % 360}°', style: const TextStyle(color: Colors.white24, fontSize: 6)), const SizedBox(width: 10), Text(mapMode ? 'MAP' : 'ORBIT', style: const TextStyle(color: Colors.white24, fontSize: 6))]]));
}

class _WorldPanel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final double phase; final VoidCallback onClose, onEnter;
  const _WorldPanel({required this.world, required this.compact, required this.phase, required this.onClose, required this.onEnter});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xF20A0912), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0x557F70B0)), boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 26)]), child: Row(children: [Container(width: 4, height: 48, decoration: BoxDecoration(color: const Color(0x667F70B0), borderRadius: BorderRadius.circular(4))), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(world.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 2.8)), const SizedBox(height: 4), Text(world.description, maxLines: compact ? 1 : 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white38, fontSize: 7.5)), const SizedBox(height: 7), Text('WORLD NODE  •  ORBIT ${(phase * 360).round() % 360}°', style: const TextStyle(color: Colors.white24, fontSize: 5.8, letterSpacing: 1.4))])), if (!compact) TextButton(onPressed: onClose, child: const Text('CLOSE', style: TextStyle(fontSize: 8))), FilledButton(onPressed: onEnter, child: const Text('ENTER', style: TextStyle(fontSize: 9)))]));
}

class _Hint extends StatelessWidget { const _Hint(); @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), decoration: BoxDecoration(color: const Color(0x88070710), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x223F3A55))), child: const Text('DRAG TO ORBIT  •  PINCH TO ZOOM  •  SELECT A WORLD', style: TextStyle(color: Colors.white38, fontSize: 6.5, letterSpacing: 1.7))); }

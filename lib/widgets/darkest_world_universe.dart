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
  double orbitOffset = 0;
  double zoom = 1;
  Offset? dragStart;
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 54))..repeat();
  @override void dispose() { clock.dispose(); super.dispose(); }
  void _select(GalaxyWorld world) => setState(() => selected = selected == world.kind ? null : world.kind);
  void _resetView() => setState(() { orbitOffset = 0; zoom = 1; selected = null; });

  @override Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 760;
    GalaxyWorld? current;
    for (final world in widget.worlds) { if (world.kind == selected) { current = world; break; } }
    return Scaffold(
      backgroundColor: const Color(0xFF010106),
      body: GestureDetector(
        onScaleStart: (details) => dragStart = details.focalPoint,
        onScaleUpdate: (details) {
          if (details.pointerCount > 1) {
            setState(() => zoom = (zoom * details.scale).clamp(.68, 1.48));
          } else if (dragStart != null) {
            final dx = details.focalPoint.dx - dragStart!.dx;
            setState(() => orbitOffset += dx / math.max(180, size.width));
            dragStart = details.focalPoint;
          }
        },
        onScaleEnd: (_) => dragStart = null,
        child: AnimatedBuilder(
          animation: clock,
          builder: (_, __) => Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _UniversePainter(clock.value, orbitOffset, selected != null))),
            Positioned(left: compact ? 18 : 34, top: compact ? 18 : 28, child: const _UniverseHeader()),
            Center(child: Transform.scale(
              scale: zoom,
              child: SizedBox(width: compact ? 360 : 900, height: compact ? 520 : 700,
                child: Stack(children: [
                  for (var i = 0; i < widget.worlds.length; i++)
                    _Planet(
                      world: widget.worlds[i], index: i, total: widget.worlds.length,
                      t: clock.value, orbitOffset: orbitOffset,
                      selected: selected == widget.worlds[i].kind, compact: compact,
                      onTap: () => _select(widget.worlds[i]),
                    ),
                ]),
              ),
            )),
            Positioned(right: compact ? 16 : 34, top: compact ? 18 : 28,
              child: _ViewControls(zoom: zoom, onZoomIn: () => setState(() => zoom = (zoom + .1).clamp(.68, 1.48)), onZoomOut: () => setState(() => zoom = (zoom - .1).clamp(.68, 1.48)), onReset: _resetView)),
            if (current != null)
              Positioned(left: compact ? 12 : 34, right: compact ? 12 : 34, bottom: compact ? 12 : 28,
                child: _WorldPanel(world: current!, compact: compact, t: clock.value, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!))),
            if (current == null)
              Positioned(left: 0, right: 0, bottom: compact ? 16 : 30, child: const Center(child: _InteractionHint())),
          ]),
        ),
      ),
    );
  }
}

class _UniverseHeader extends StatelessWidget {
  const _UniverseHeader();
  @override Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('DARKESTWORLD', style: TextStyle(fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300)),
    const SizedBox(height: 7),
    Text('GALAXY / WORLDS', style: TextStyle(fontSize: 7, letterSpacing: 2.8, color: Colors.white.withValues(alpha: .35))),
  ]);
}

class _InteractionHint extends StatelessWidget {
  const _InteractionHint();
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(color: const Color(0x66070710), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0x223F3A55))),
    child: Text('DRAG TO ORBIT  •  PINCH TO ZOOM  •  SELECT A WORLD', style: TextStyle(fontSize: 7, letterSpacing: 1.7, color: Colors.white.withValues(alpha: .38))));
}

class _ViewControls extends StatelessWidget {
  final double zoom; final VoidCallback onZoomIn, onZoomOut, onReset;
  const _ViewControls({required this.zoom, required this.onZoomIn, required this.onZoomOut, required this.onReset});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: const Color(0x99101019), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0x223F3A55))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      _Control(icon: Icons.remove, onTap: onZoomOut),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 7), child: Text('${(zoom * 100).round()}%', style: const TextStyle(fontSize: 7, letterSpacing: 1))),
      _Control(icon: Icons.add, onTap: onZoomIn),
      const SizedBox(width: 4), _Control(icon: Icons.refresh, onTap: onReset),
    ]));
}
class _Control extends StatelessWidget { final IconData icon; final VoidCallback onTap; const _Control({required this.icon,required this.onTap}); @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(8),child:Padding(padding:const EdgeInsets.all(6),child:Icon(icon,size:12,color:Colors.white54))); }

class _Planet extends StatelessWidget {
  final GalaxyWorld world; final int index, total; final double t, orbitOffset; final bool selected, compact; final VoidCallback onTap;
  const _Planet({required this.world, required this.index, required this.total, required this.t, required this.orbitOffset, required this.selected, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) {
    final angle = -math.pi / 2 + index * math.pi * 2 / math.max(1, total) + t * .16 + orbitOffset;
    final orbit = compact ? 145.0 : 270.0;
    final center = Offset(compact ? 180 : 450, compact ? 260 : 350);
    final depth = (.55 + .45 * ((math.sin(angle) + 1) / 2));
    final position = Offset(center.dx + math.cos(angle) * orbit * .72, center.dy + math.sin(angle) * orbit * .55);
    final base = compact ? 80.0 : 112.0;
    final size = selected ? base * 1.52 : base * (.68 + depth * .34);
    final opacity = selected ? 1.0 : (.28 + depth * .72);
    return Positioned(left: position.dx - size / 2, top: position.dy - size / 2, width: size, height: size + 30,
      child: Opacity(opacity: opacity, child: GestureDetector(onTap: onTap, child: Column(children: [
        SizedBox(width: size, height: size, child: CustomPaint(painter: _PlanetPainter(index, selected, t, depth))),
        const SizedBox(height: 7),
        Text(world.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: selected ? 10 : 7, letterSpacing: 2.2, color: Colors.white.withValues(alpha: selected ? .92 : .45))),
      ]))));
  }
}

class _WorldPanel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final double t; final VoidCallback onClose, onEnter;
  const _WorldPanel({required this.world, required this.compact, required this.t, required this.onClose, required this.onEnter});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xF20A0913), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0x557F70B0)), boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 24)]),
    child: Row(children: [
      Container(width: 5, height: 48, decoration: BoxDecoration(color: const Color(0x667F70B0), borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(world.title.toUpperCase(), style: const TextStyle(fontSize: 14, letterSpacing: 3)), const SizedBox(width: 10), Text('WORLD NODE', style: TextStyle(fontSize: 6, letterSpacing: 1.8, color: Colors.white.withValues(alpha: .26)))]),
        const SizedBox(height: 5), Text(world.description, style: const TextStyle(fontSize: 8, color: Colors.white38)),
        const SizedBox(height: 8), Text('ORBITAL POSITION  •  ${(t * 360).round() % 360}°', style: TextStyle(fontSize: 6, letterSpacing: 1.6, color: Colors.white.withValues(alpha: .25))),
      ])),
      if (!compact) TextButton(onPressed: onClose, child: const Text('CLOSE')),
      FilledButton(onPressed: onEnter, child: const Text('ENTER')),
    ]));
}

class _UniversePainter extends CustomPainter {
  final double t, orbitOffset; final bool focused;
  const _UniversePainter(this.t, this.orbitOffset, this.focused);
  @override void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.10), radius: 1.22, colors: [Color(0xFF30254A), Color(0xFF0A0914), Color(0xFF010105)]).createShader(rect));
    final stars = math.Random(417);
    for (var i = 0; i < 780; i++) {
      final layer = i % 4;
      final speed = [.002, .005, .010, .020][layer];
      final x = (stars.nextDouble() * s.width + t * s.width * speed + orbitOffset * s.width * (.10 + layer * .08)) % s.width;
      final y = stars.nextDouble() * s.height;
      final twinkle = .010 + .045 * (.5 + .5 * math.sin(t * math.pi * 2 + i * 1.71));
      c.drawCircle(Offset(x, y), .08 + stars.nextDouble() * (layer == 3 ? 1.05 : .68), Paint()..color = Colors.white.withValues(alpha: twinkle));
    }
    final center = Offset(s.width * .5, s.height * .49);
    for (var k = 0; k < 14; k++) {
      final wobble = math.sin(t * math.pi * 2 + k) * .005;
      c.drawOval(Rect.fromCenter(center: center, width: s.width * (.43 + k * .076 + wobble), height: s.height * (.50 + k * .079)), Paint()..style = PaintingStyle.stroke..strokeWidth = k == 0 ? 1.25 : .32..color = const Color(0x169A8CC0));
    }
    final nebula = Paint()..shader = RadialGradient(colors: [Color.fromRGBO(127,112,176, focused ? .20 : .15), const Color(0x087F70B0), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: s.shortestSide * .55));
    c.drawCircle(center, s.shortestSide * .55, nebula);
    for (var i = 0; i < 12; i++) {
      final a = t * math.pi * 2 * (i.isEven ? .016 : -.011) + i * .71 + orbitOffset * .4;
      final p = Offset(center.dx + math.cos(a) * s.width * (.24 + i * .027), center.dy + math.sin(a) * s.height * (.18 + i * .018));
      c.drawCircle(p, 1.0 + i * .42, Paint()..color = const Color(0x3DACA5C5));
    }
    final dust = Paint()..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.transparent, const Color(0x0AFFFFFF), Colors.transparent]).createShader(rect);
    c.drawRect(rect, dust);
    final vignette = Paint()..shader = const RadialGradient(colors: [Colors.transparent, Color(0x5A000000)]).createShader(Rect.fromCenter(center: center, width: s.width * 1.1, height: s.height * 1.1));
    c.drawRect(rect, vignette);
  }
  @override bool shouldRepaint(covariant _UniversePainter old) => old.t != t || old.orbitOffset != orbitOffset || old.focused != focused;
}

class _PlanetPainter extends CustomPainter {
  final int seed; final bool active; final double t, depth;
  const _PlanetPainter(this.seed, this.active, this.t, this.depth);
  double _noise(math.Random r) => r.nextDouble() * 2 - 1;
  Path _landmass(math.Random r, Offset center, double radius, double sx, double sy, double rotation) {
    final path = Path(); const points = 54;
    for (var i = 0; i < points; i++) {
      final a = rotation + i * math.pi * 2 / points;
      final wave = math.sin(i * 1.37 + seed) * .12 + math.sin(i * .43 + seed * .7) * .10 + math.sin(i * .19 + seed * 1.9) * .06;
      final rr = radius * (.66 + wave + _noise(r) * .16);
      final p = Offset(center.dx + math.cos(a) * rr * sx, center.dy + math.sin(a) * rr * sy);
      if (i == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy);
    }
    path.close(); return path;
  }
  void _drawMoon(covariant Canvas c, Offset center, double radius, double phase, double orbit, int index) {
    final a = phase + index * 2.4;
    final p = Offset(center.dx + math.cos(a) * orbit, center.dy + math.sin(a) * orbit * .42);
    c.drawCircle(p, radius, Paint()..color = Colors.white.withValues(alpha: .16));
    c.drawCircle(p, radius * .55, Paint()..color = const Color(0x22000000));
  }
  @override void paint(Canvas c, Size s) {
    final rnd = math.Random(seed * 731 + 19);
    final center = Offset(s.width * .47, s.height * .45);
    final rad = s.shortestSide * .475;
    final outer = rad + (active ? 5 : 3);
    // Far planetary halo.
    c.drawCircle(center, outer + 7, Paint()..shader = RadialGradient(colors: [const Color(0x187F70B0), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: outer + 7)));
    // Sparse moons make worlds read as systems, not flat icons.
    if (seed % 3 != 1) { _drawMoon(c, center, rad * .035, t * math.pi * 2 + seed, rad * 1.72, 0); }
    if (seed % 5 == 0) { _drawMoon(c, center, rad * .022, -t * math.pi * 2 + seed, rad * 1.42, 1); }

    final globe = Paint()..shader = const RadialGradient(center: Alignment(-.38, -.42), radius: 1.04,
      colors: [Color(0xFF9A95AA), Color(0xFF615B70), Color(0xFF2B2936), Color(0xFF05060A)]).createShader(Offset.zero & s);
    c.drawCircle(center, rad, globe);
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: rad * .985)));
    c.drawCircle(center, rad * .98, Paint()..color = const Color(0x283E3A50));

    // Global latitude/circulation structure.
    for (var band = 0; band < 12; band++) {
      final y = center.dy - rad * .84 + band * rad * .152;
      final warp = math.sin(t * math.pi * 2 + band) * rad * .009;
      c.drawOval(Rect.fromCenter(center: Offset(center.dx + warp, y), width: rad * (1.02 + band * .10), height: rad * .095), Paint()..style = PaintingStyle.stroke..strokeWidth = .30..color = Colors.white.withValues(alpha: .014));
    }

    // Continents + basins + elevation contours.
    for (var n = 0; n < 16; n++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final anchor = Offset(center.dx + math.cos(angle) * rad * (.08 + rnd.nextDouble() * .46), center.dy + math.sin(angle) * rad * (.07 + rnd.nextDouble() * .40));
      final rr = rad * (.095 + rnd.nextDouble() * .22);
      final path = _landmass(rnd, anchor, rr, .66 + rnd.nextDouble() * .76, .44 + rnd.nextDouble() * .76, rnd.nextDouble() * math.pi);
      c.drawPath(path, Paint()..color = Color.fromRGBO(66 + n % 6 * 7, 63 + n % 5 * 7, 76 + n % 6 * 7, .14 + n % 4 * .025));
      c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1.12 : .48..color = Colors.white.withValues(alpha: active ? .13 : .038));
      for (var layer = 1; layer <= 8; layer++) {
        final shift = Offset(-rad * .006 * layer, -rad * .0035 * layer);
        c.drawPath(path.shift(shift), Paint()..style = PaintingStyle.stroke..strokeWidth = .26 + layer * .05..color = Colors.white.withValues(alpha: active ? .043 : .016));
      }
      for (var ridge = 0; ridge < 10; ridge++) {
        final p = Offset(anchor.dx + _noise(rnd) * rr * .56, anchor.dy + _noise(rnd) * rr * .38);
        final rect = Rect.fromCenter(center: p, width: rr * (.24 + rnd.nextDouble() * .82), height: rr * (.07 + rnd.nextDouble() * .23));
        c.drawArc(rect, rnd.nextDouble() * math.pi, .30 + rnd.nextDouble() * .95, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .30..color = Colors.white.withValues(alpha: active ? .060 : .022));
      }
      // Dark basin edge below the relief.
      c.drawPath(path.shift(Offset(rad * .006, rad * .008)), Paint()..style = PaintingStyle.stroke..strokeWidth = .55..color = Colors.black.withValues(alpha: .06));
    }

    // Polar structures.
    final cap = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Colors.white.withValues(alpha: .12), Colors.white.withValues(alpha: .025), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: rad));
    c.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy - rad * .84), width: rad * 1.16, height: rad * .32), cap);
    c.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + rad * .84), width: rad * .98, height: rad * .27), cap);

    // High-frequency terrain / impact detail.
    for (var i = 0; i < 260; i++) {
      final x = center.dx + _noise(rnd) * rad * .92;
      final y = center.dy + _noise(rnd) * rad * .92;
      final rr = .13 + rnd.nextDouble() * 1.22;
      c.drawCircle(Offset(x, y), rr, Paint()..color = Colors.white.withValues(alpha: .009 + rnd.nextDouble() * .034));
      if (i % 17 == 0) {
        c.drawCircle(Offset(x, y), rr * 2.3, Paint()..style = PaintingStyle.stroke..strokeWidth = .22..color = Colors.black.withValues(alpha: .04));
        c.drawCircle(Offset(x - rr * .7, y - rr * .45), rr * .42, Paint()..color = Colors.white.withValues(alpha: .025));
      }
    }

    // Cloud deck: separate, brighter and slightly offset from terrain.
    for (var cloud = 0; cloud < 18; cloud++) {
      final y = center.dy + (cloud - 9) * rad * .094 + math.sin(t * math.pi * 2 + cloud * .73 + seed) * rad * .010;
      final start = math.pi * (.04 + rnd.nextDouble() * .44) + t * (.035 + seed * .001);
      c.drawArc(Rect.fromCenter(center: Offset(center.dx, y), width: rad * (1.18 + rnd.nextDouble() * .52), height: rad * (.075 + rnd.nextDouble() * .13)), start, math.pi * (.22 + rnd.nextDouble() * .42), false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = .42 + rnd.nextDouble() * .72..color = Colors.white.withValues(alpha: .014 + rnd.nextDouble() * .034));
    }
    c.restore();

    // Sphere lighting, terminator and reflected night-side fill.
    c.drawCircle(center, rad, Paint()..shader = const RadialGradient(center: Alignment(-.46, -.48), radius: .75,
      colors: [Colors.transparent, Color(0x10000000), Color(0x60000000), Color(0xE4000000)]).createShader(Offset.zero & s));
    c.drawCircle(center, rad, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Colors.transparent, Color(0x08000000), Color(0x5B000000)]).createShader(Offset.zero & s));
    final rim = Paint()..shader = RadialGradient(center: Alignment(-.48, -.50), radius: .76,
      colors: [const Color(0x248F87A5), const Color(0x088F87A5), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: rad));
    c.drawCircle(center, rad, rim);

    // Atmospheric shell, limb glow and thin high-altitude sweep.
    c.drawCircle(center, rad + 1.4, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 3.2 : 1.25..color = Colors.white.withValues(alpha: active ? .22 : .06));
    c.drawCircle(center, rad + 4.5, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1.0 : .45..color = const Color(0x207F70B0));
    c.drawArc(Rect.fromCircle(center: center, radius: rad + 3.0), math.pi * 1.01, math.pi * .64, false, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 2.3 : 1.0..color = const Color(0x527F70B0));
    c.drawArc(Rect.fromCircle(center: center, radius: rad + 2.0), t * math.pi * 2 + seed, math.pi * .16, false, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1.8 : .65..color = Colors.white.withValues(alpha: active ? .12 : .028));
    c.drawCircle(Offset(center.dx - rad * .34, center.dy - rad * .35), rad * .74, Paint()..shader = RadialGradient(colors: [const Color(0x208F87A8), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(center.dx - rad * .34, center.dy - rad * .35), radius: rad * .74)));

    // Tiny night-side reflected light makes the silhouette readable without flattening it.
    final reflected = Paint()..shader = RadialGradient(center: Alignment(.72, .62), radius: .70, colors: [const Color(0x101B1730), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: rad));
    c.drawCircle(center, rad, reflected);
  }
  @override bool shouldRepaint(covariant _PlanetPainter old) => old.seed != seed || old.active != active || old.t != t || old.depth != depth;
}

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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 48))..repeat();
  @override void dispose() { clock.dispose(); super.dispose(); }

  void _select(GalaxyWorld world) => setState(() => selected = selected == world.kind ? null : world.kind);
  void _resetView() => setState(() { orbitOffset = 0; zoom = 1; });

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
            setState(() => zoom = (zoom * details.scale).clamp(.72, 1.38));
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
            Positioned.fill(child: CustomPaint(painter: _UniversePainter(clock.value, orbitOffset))),
            Positioned(left: compact ? 18 : 34, top: compact ? 18 : 28, child: const _UniverseHeader()),
            Center(child: Transform.scale(
              scale: zoom,
              child: SizedBox(width: compact ? 360 : 900, height: compact ? 520 : 700,
                child: CustomMultiChildLayout(
                  delegate: _GalaxyLayoutDelegate(),
                  children: [
                    for (var i = 0; i < widget.worlds.length; i++)
                      LayoutId(
                        id: i,
                        child: _Planet(
                          world: widget.worlds[i], index: i, total: widget.worlds.length,
                          t: clock.value, orbitOffset: orbitOffset,
                          selected: selected == widget.worlds[i].kind, compact: compact,
                          onTap: () => _select(widget.worlds[i]),
                        ),
                      ),
                  ],
                ),
              ),
            )),
            Positioned(right: compact ? 16 : 34, top: compact ? 18 : 28,
              child: _ViewControls(zoom: zoom, onZoomIn: () => setState(() => zoom = (zoom + .1).clamp(.72, 1.38)), onZoomOut: () => setState(() => zoom = (zoom - .1).clamp(.72, 1.38)), onReset: _resetView)),
            if (current != null)
              Positioned(left: compact ? 12 : 34, right: compact ? 12 : 34, bottom: compact ? 12 : 28,
                child: _Panel(world: current!, compact: compact, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!))),
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
      const SizedBox(width: 4),
      _Control(icon: Icons.refresh, onTap: onReset),
    ]));
}
class _Control extends StatelessWidget { final IconData icon; final VoidCallback onTap; const _Control({required this.icon,required this.onTap}); @override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(8),child:Padding(padding:const EdgeInsets.all(6),child:Icon(icon,size:12,color:Colors.white54))); }

class _GalaxyLayoutDelegate extends MultiChildLayoutDelegate {
  @override void performLayout(Size size) { for (var i = 0; i < 32; i++) { if (hasChild(i)) layoutChild(i, BoxConstraints.loose(size)); } }
  @override bool shouldRelayout(covariant _GalaxyLayoutDelegate oldDelegate) => false;
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world; final int index, total; final double t, orbitOffset; final bool selected, compact; final VoidCallback onTap;
  const _Planet({required this.world, required this.index, required this.total, required this.t, required this.orbitOffset, required this.selected, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) {
    final angle = -math.pi / 2 + index * math.pi * 2 / math.max(1, total) + t * .20 + orbitOffset;
    final orbit = compact ? 145.0 : 270.0;
    final center = Offset(compact ? 180 : 450, compact ? 260 : 350);
    final depth = (.62 + .38 * ((math.sin(angle) + 1) / 2));
    final position = Offset(center.dx + math.cos(angle) * orbit * .72, center.dy + math.sin(angle) * orbit * .55);
    final base = compact ? 80.0 : 112.0;
    final size = selected ? base * 1.42 : base * (.72 + depth * .30);
    final opacity = selected ? 1.0 : (.38 + depth * .62);
    return SizedBox(width: size + 70, height: size + 34, child: Transform.translate(offset: Offset(position.dx - center.dx - size / 2, position.dy - center.dy - size / 2),
      child: Opacity(opacity: opacity, child: GestureDetector(onTap: onTap, child: Column(children: [
        Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: const RadialGradient(center: Alignment(-.38, -.42), radius: .93, colors: [Color(0xFF8C87A2), Color(0xFF353149), Color(0xFF080910)]),
          border: Border.all(color: Colors.white.withValues(alpha: selected ? .40 : .10)),
          boxShadow: selected ? const [BoxShadow(color: Color(0x557F70B0), blurRadius: 46, spreadRadius: 4)] : const []),
          child: CustomPaint(painter: _PlanetPainter(index, selected, t))),
        const SizedBox(height: 7),
        Text(world.title, style: TextStyle(fontSize: selected ? 10 : 7, letterSpacing: 2.2, color: Colors.white.withValues(alpha: selected ? .92 : .45))),
      ]))));
  }
}

class _Panel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final VoidCallback onClose, onEnter;
  const _Panel({required this.world, required this.compact, required this.onClose, required this.onEnter});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xF20A0913), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0x557F70B0)), boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 24)]),
    child: Row(children: [
      Container(width: 5, height: 44, decoration: BoxDecoration(color: const Color(0x667F70B0), borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(world.title.toUpperCase(), style: const TextStyle(fontSize: 14, letterSpacing: 3)),
        const SizedBox(height: 5), Text(world.description, style: const TextStyle(fontSize: 8, color: Colors.white38)),
        const SizedBox(height: 8), Text('WORLD NODE  •  SELECTED', style: TextStyle(fontSize: 6, letterSpacing: 1.7, color: Colors.white.withValues(alpha: .28))),
      ])),
      if (!compact) TextButton(onPressed: onClose, child: const Text('CLOSE')),
      FilledButton(onPressed: onEnter, child: const Text('ENTER')),
    ]));
}

class _UniversePainter extends CustomPainter {
  final double t, orbitOffset; const _UniversePainter(this.t, this.orbitOffset);
  @override void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.2, colors: [Color(0xFF282044), Color(0xFF090812), Color(0xFF010105)]).createShader(rect));
    final stars = math.Random(417);
    for (var i = 0; i < 620; i++) {
      final layer = i % 3;
      final speed = layer == 0 ? .004 : layer == 1 ? .009 : .018;
      final x = (stars.nextDouble() * s.width + t * s.width * speed + orbitOffset * s.width * (.18 + layer * .12)) % s.width;
      final y = stars.nextDouble() * s.height;
      final twinkle = .014 + .040 * (.5 + .5 * math.sin(t * math.pi * 2 + i * 1.71));
      c.drawCircle(Offset(x, y), .10 + stars.nextDouble() * (layer == 2 ? .95 : .62), Paint()..color = Colors.white.withValues(alpha: twinkle));
    }
    final center = Offset(s.width * .5, s.height * .49);
    for (var k = 0; k < 12; k++) {
      final wobble = math.sin(t * math.pi * 2 + k) * .006;
      c.drawOval(Rect.fromCenter(center: center, width: s.width * (.45 + k * .074 + wobble), height: s.height * (.52 + k * .076)), Paint()..style = PaintingStyle.stroke..strokeWidth = k == 0 ? 1.2 : .34..color = const Color(0x159A8CC0));
    }
    final nebula = Paint()..shader = RadialGradient(colors: [const Color(0x2B7F70B0), const Color(0x087F70B0), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: s.shortestSide * .52));
    c.drawCircle(center, s.shortestSide * .52, nebula);
    for (var i = 0; i < 9; i++) {
      final a = t * math.pi * 2 * (i.isEven ? .018 : -.013) + i * .71 + orbitOffset * .4;
      final p = Offset(center.dx + math.cos(a) * s.width * (.27 + i * .025), center.dy + math.sin(a) * s.height * (.20 + i * .018));
      c.drawCircle(p, 1.1 + i * .45, Paint()..color = const Color(0x3DACA5C5));
    }
    final vignette = Paint()..shader = const RadialGradient(colors: [Colors.transparent, Color(0x50000000)]).createShader(Rect.fromCenter(center: center, width: s.width * 1.1, height: s.height * 1.1));
    c.drawRect(rect, vignette);
  }
  @override bool shouldRepaint(covariant _UniversePainter old) => old.t != t || old.orbitOffset != orbitOffset;
}

class _PlanetPainter extends CustomPainter {
  final int seed; final bool active; final double t; const _PlanetPainter(this.seed, this.active, this.t);
  double _noise(math.Random r) => r.nextDouble() * 2 - 1;
  Path _landmass(math.Random r, Offset center, double radius, double sx, double sy, double rotation) {
    final path = Path(); const points = 46;
    for (var i = 0; i < points; i++) {
      final a = rotation + i * math.pi * 2 / points;
      final wave = math.sin(i * 1.37 + seed) * .13 + math.sin(i * .43 + seed * .7) * .10;
      final rr = radius * (.68 + wave + _noise(r) * .18);
      final p = Offset(center.dx + math.cos(a) * rr * sx, center.dy + math.sin(a) * rr * sy);
      if (i == 0) path.moveTo(p.dx, p.dy); else path.lineTo(p.dx, p.dy);
    }
    path.close(); return path;
  }
  @override void paint(Canvas c, Size s) {
    final rnd = math.Random(seed * 731 + 19); final center = Offset(s.width * .47, s.height * .45); final rad = s.shortestSide * .475;
    c.drawCircle(center, rad, Paint()..shader = const RadialGradient(center: Alignment(-.38, -.42), radius: 1.04, colors: [Color(0xFF8A849C), Color(0xFF57516A), Color(0xFF242331), Color(0xFF05060A)]).createShader(Offset.zero & s));
    c.save(); c.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: rad * .985)));
    c.drawCircle(center, rad * .98, Paint()..color = const Color(0x243A3850));

    // Latitude / atmospheric circulation structure.
    for (var band = 0; band < 9; band++) {
      final y = center.dy - rad * .82 + band * rad * .205;
      c.drawOval(Rect.fromCenter(center: Offset(center.dx, y), width: rad * (1.08 + band * .09), height: rad * .11), Paint()..style = PaintingStyle.stroke..strokeWidth = .35..color = Colors.white.withValues(alpha: .015));
    }

    // Continents, basins and multiple elevation contours.
    for (var n = 0; n < 14; n++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final anchor = Offset(center.dx + math.cos(angle) * rad * (.10 + rnd.nextDouble() * .45), center.dy + math.sin(angle) * rad * (.09 + rnd.nextDouble() * .38));
      final rr = rad * (.10 + rnd.nextDouble() * .23);
      final path = _landmass(rnd, anchor, rr, .70 + rnd.nextDouble() * .70, .48 + rnd.nextDouble() * .70, rnd.nextDouble() * math.pi);
      c.drawPath(path, Paint()..color = Color.fromRGBO(67 + n % 5 * 8, 64 + n % 4 * 8, 78 + n % 5 * 8, .15 + n % 3 * .035));
      c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1.05 : .52..color = Colors.white.withValues(alpha: active ? .13 : .045));
      for (var layer = 1; layer <= 7; layer++) {
        final shift = Offset(-rad * .007 * layer, -rad * .004 * layer);
        c.drawPath(path.shift(shift), Paint()..style = PaintingStyle.stroke..strokeWidth = .30 + layer * .055..color = Colors.white.withValues(alpha: active ? .044 : .018));
      }
      for (var ridge = 0; ridge < 9; ridge++) {
        final p = Offset(anchor.dx + _noise(rnd) * rr * .55, anchor.dy + _noise(rnd) * rr * .38);
        c.drawArc(Rect.fromCenter(center: p, width: rr * (.28 + rnd.nextDouble() * .78), height: rr * (.08 + rnd.nextDouble() * .24)), rnd.nextDouble() * math.pi, .32 + rnd.nextDouble() * .9, false, Paint()..style = PaintingStyle.stroke..strokeWidth = .35..color = Colors.white.withValues(alpha: active ? .065 : .025));
      }
    }

    // Polar structures and high-altitude haze.
    final cap = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .11), Colors.white.withValues(alpha: .02), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: rad));
    c.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy - rad * .83), width: rad * 1.15, height: rad * .34), cap);
    c.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + rad * .83), width: rad * .95, height: rad * .28), cap);

    // Dense micro terrain / impact texture.
    for (var i = 0; i < 230; i++) {
      final x = center.dx + _noise(rnd) * rad * .92, y = center.dy + _noise(rnd) * rad * .92;
      final rr = .16 + rnd.nextDouble() * 1.3;
      c.drawCircle(Offset(x, y), rr, Paint()..color = Colors.white.withValues(alpha: .010 + rnd.nextDouble() * .038));
      if (i % 13 == 0) c.drawCircle(Offset(x, y), rr * 2.0, Paint()..style = PaintingStyle.stroke..strokeWidth = .22..color = Colors.black.withValues(alpha: .035));
    }

    // Cloud belts / high atmosphere with slow drift.
    for (var cloud = 0; cloud < 15; cloud++) {
      final y = center.dy + (cloud - 7) * rad * .105 + math.sin(t * math.pi * 2 + cloud * .8) * rad * .012;
      final start = math.pi * (.06 + rnd.nextDouble() * .38) + t * .04;
      c.drawArc(Rect.fromCenter(center: Offset(center.dx, y), width: rad * (1.25 + rnd.nextDouble() * .45), height: rad * (.10 + rnd.nextDouble() * .14)), start, math.pi * (.24 + rnd.nextDouble() * .40), false, Paint()..style = PaintingStyle.stroke..strokeWidth = .45 + rnd.nextDouble() * .7..color = Colors.white.withValues(alpha: .018 + rnd.nextDouble() * .038));
    }
    c.restore();

    // Deep spherical shadow and terminator.
    c.drawCircle(center, rad, Paint()..shader = const RadialGradient(center: Alignment(-.46, -.48), radius: .76, colors: [Colors.transparent, Color(0x12000000), Color(0x68000000), Color(0xE0000000)]).createShader(Offset.zero & s));
    c.drawCircle(center, rad, Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.transparent, Color(0x09000000), Color(0x58000000)]).createShader(Offset.zero & s));

    // Atmospheric shell, halo and moving illuminated limb.
    c.drawCircle(center, rad + 1.4, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 3.0 : 1.35..color = Colors.white.withValues(alpha: active ? .20 : .07));
    c.drawArc(Rect.fromCircle(center: center, radius: rad + 3.0), math.pi * 1.02, math.pi * .62, false, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 2.2 : 1.0..color = const Color(0x467F70B0));
    c.drawArc(Rect.fromCircle(center: center, radius: rad + 2.0), t * math.pi * 2 + seed, math.pi * .18, false, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1.7 : .7..color = Colors.white.withValues(alpha: active ? .11 : .035));
    c.drawCircle(Offset(center.dx - rad * .34, center.dy - rad * .35), rad * .72, Paint()..shader = RadialGradient(colors: [const Color(0x1D8E83A8), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(center.dx - rad * .34, center.dy - rad * .35), radius: rad * .72)));
  }
  @override bool shouldRepaint(covariant _PlanetPainter old) => old.seed != seed || old.active != active || old.t != t;
}

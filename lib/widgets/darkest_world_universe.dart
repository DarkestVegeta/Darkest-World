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
  late final AnimationController clock = AnimationController(vsync: this, duration: const Duration(seconds: 42))..repeat();
  @override void dispose() { clock.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    GalaxyWorld? current;
    for (final world in widget.worlds) { if (world.kind == selected) { current = world; break; } }
    return Scaffold(
      backgroundColor: const Color(0xFF010106),
      body: AnimatedBuilder(
        animation: clock,
        builder: (_, __) => Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _UniversePainter(clock.value))),
          Positioned(left: compact ? 18 : 34, top: compact ? 18 : 28, child: const Text('DARKESTWORLD', style: TextStyle(fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300))),
          Center(child: SizedBox(width: compact ? 360 : 900, height: compact ? 520 : 700, child: Stack(children: [
            for (var i = 0; i < widget.worlds.length; i++)
              _Planet(
                world: widget.worlds[i], index: i, total: widget.worlds.length, t: clock.value,
                selected: selected == widget.worlds[i].kind, compact: compact,
                onTap: () => setState(() => selected = selected == widget.worlds[i].kind ? null : widget.worlds[i].kind),
              ),
          ]))),
          if (current != null)
            Positioned(left: compact ? 14 : 34, right: compact ? 14 : 34, bottom: compact ? 14 : 28,
              child: _Panel(world: current, compact: compact, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!))),
        ]),
      ),
    );
  }
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world; final int index, total; final double t; final bool selected, compact; final VoidCallback onTap;
  const _Planet({required this.world, required this.index, required this.total, required this.t, required this.selected, required this.compact, required this.onTap});
  @override Widget build(BuildContext context) {
    final angle = -math.pi / 2 + index * math.pi * 2 / math.max(1, total) + t * .22;
    final orbit = compact ? 145.0 : 270.0;
    final center = Offset(compact ? 180 : 450, compact ? 260 : 350);
    final position = Offset(center.dx + math.cos(angle) * orbit * .72, center.dy + math.sin(angle) * orbit * .55);
    final size = selected ? (compact ? 122.0 : 164.0) : (compact ? 82.0 : 114.0);
    return Positioned(left: position.dx - size / 2, top: position.dy - size / 2,
      child: GestureDetector(onTap: onTap, child: Column(children: [
        Container(width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle,
            gradient: const RadialGradient(center: Alignment(-.38, -.42), radius: .93, colors: [Color(0xFF8C87A2), Color(0xFF353149), Color(0xFF080910)]),
            border: Border.all(color: Colors.white.withValues(alpha: selected ? .38 : .10)),
            boxShadow: selected ? const [BoxShadow(color: Color(0x557F70B0), blurRadius: 46, spreadRadius: 4)] : const []),
          child: CustomPaint(painter: _PlanetPainter(index, selected, t)),
        ),
        const SizedBox(height: 8),
        Text(world.title, style: TextStyle(fontSize: selected ? 10 : 7, letterSpacing: 2.2, color: Colors.white.withValues(alpha: selected ? .9 : .45))),
      ]));
  }
}

class _Panel extends StatelessWidget {
  final GalaxyWorld world; final bool compact; final VoidCallback onClose, onEnter;
  const _Panel({required this.world, required this.compact, required this.onClose, required this.onEnter});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xEE080812), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0x557F70B0))),
    child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(world.title.toUpperCase(), style: const TextStyle(fontSize: 14, letterSpacing: 3)), const SizedBox(height: 5),
      Text(world.description, style: const TextStyle(fontSize: 8, color: Colors.white38)),
    ])), if (!compact) TextButton(onPressed: onClose, child: const Text('CLOSE')), FilledButton(onPressed: onEnter, child: const Text('ENTER'))]));
}

class _UniversePainter extends CustomPainter {
  final double t; const _UniversePainter(this.t);
  @override void paint(Canvas c, Size s) {
    final rect = Offset.zero & s;
    c.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.08), radius: 1.2, colors: [Color(0xFF282044), Color(0xFF090812), Color(0xFF010105)]).createShader(rect));
    final stars = math.Random(417);
    for (var i = 0; i < 520; i++) {
      final x = (stars.nextDouble() * s.width + t * s.width * .012 * (i.isEven ? 1 : -.35)) % s.width;
      final y = stars.nextDouble() * s.height;
      final twinkle = .018 + .038 * (.5 + .5 * math.sin(t * math.pi * 2 + i * 1.71));
      c.drawCircle(Offset(x, y), .12 + stars.nextDouble() * .78, Paint()..color = Colors.white.withValues(alpha: twinkle));
    }
    final center = Offset(s.width * .5, s.height * .49);
    for (var k = 0; k < 10; k++) {
      c.drawOval(Rect.fromCenter(center: center, width: s.width * (.48 + k * .075), height: s.height * (.55 + k * .078)),
        Paint()..style = PaintingStyle.stroke..strokeWidth = k == 0 ? 1.2 : .38..color = const Color(0x159A8CC0));
    }
    final nebula = Paint()..shader = RadialGradient(colors: [const Color(0x2B7F70B0), const Color(0x087F70B0), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: s.shortestSide * .48));
    c.drawCircle(center, s.shortestSide * .48, nebula);
    for (var i = 0; i < 5; i++) {
      final a = t * math.pi * 2 * (i.isEven ? .025 : -.018) + i;
      final p = Offset(center.dx + math.cos(a) * s.width * .38, center.dy + math.sin(a) * s.height * .27);
      c.drawCircle(p, 1.5 + i * .7, Paint()..color = const Color(0x3DACA5C5));
    }
  }
  @override bool shouldRepaint(covariant _UniversePainter old) => old.t != t;
}

class _PlanetPainter extends CustomPainter {
  final int seed; final bool active; final double t;
  const _PlanetPainter(this.seed, this.active, this.t);
  double _noise(math.Random r) => r.nextDouble() * 2 - 1;
  Path _landmass(math.Random r, Offset center, double radius, double sx, double sy, double rotation) {
    final path = Path();
    const points = 42;
    final values = <double>[];
    for (var i = 0; i < points; i++) {
      final wave = math.sin(i * 1.37 + seed) * .12 + math.sin(i * .43 + seed * .7) * .09;
      values.add(.68 + wave + _noise(r) * .20);
    }
    for (var i = 0; i < points; i++) {
      final a = rotation + i * math.pi * 2 / points;
      final rr = radius * values[i];
      final x = center.dx + math.cos(a) * rr * sx;
      final y = center.dy + math.sin(a) * rr * sy;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    return path;
  }
  @override void paint(Canvas c, Size s) {
    final rnd = math.Random(seed * 731 + 19);
    final center = Offset(s.width * .47, s.height * .45);
    final rad = s.shortestSide * .475;
    final globe = Paint()..shader = const RadialGradient(center: Alignment(-.38, -.42), radius: 1.04,
      colors: [Color(0xFF8A849C), Color(0xFF57516A), Color(0xFF242331), Color(0xFF05060A)]).createShader(Offset.zero & s);
    c.drawCircle(center, rad, globe);
    c.save();
    c.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: rad * .985)));

    // Deep base/ocean layer.
    c.drawCircle(center, rad * .98, Paint()..color = const Color(0x243A3850));
    for (var band = 0; band < 7; band++) {
      final y = center.dy - rad * .76 + band * rad * .25;
      c.drawOval(Rect.fromCenter(center: Offset(center.dx, y), width: rad * (1.15 + band * .08), height: rad * .13),
        Paint()..style = PaintingStyle.stroke..strokeWidth = .42..color = Colors.white.withValues(alpha: .018));
    }

    // Major fictional continents with coast, interior relief and basin shadows.
    final continents = <Path>[];
    for (var n = 0; n < 13; n++) {
      final angle = rnd.nextDouble() * math.pi * 2;
      final anchor = Offset(center.dx + math.cos(angle) * rad * (.12 + rnd.nextDouble() * .42), center.dy + math.sin(angle) * rad * (.10 + rnd.nextDouble() * .36));
      final rr = rad * (.12 + rnd.nextDouble() * .22);
      final sx = .72 + rnd.nextDouble() * .65;
      final sy = .48 + rnd.nextDouble() * .68;
      final path = _landmass(rnd, anchor, rr, sx, sy, rnd.nextDouble() * math.pi);
      continents.add(path);
      c.drawPath(path, Paint()..color = Color.fromRGBO(70 + n % 4 * 8, 67 + n % 5 * 7, 79 + n % 4 * 9, .16 + (n % 3) * .035));
      c.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1.05 : .62..color = Colors.white.withValues(alpha: active ? .12 : .055));
      for (var layer = 1; layer <= 6; layer++) {
        final dx = -rad * .009 * layer;
        final dy = -rad * .006 * layer;
        c.drawPath(path.shift(Offset(dx, dy)), Paint()..style = PaintingStyle.stroke..strokeWidth = .35 + layer * .055..color = Colors.white.withValues(alpha: active ? .045 : .021));
      }
      for (var ridge = 0; ridge < 7; ridge++) {
        final p = Offset(anchor.dx + _noise(rnd) * rr * .55, anchor.dy + _noise(rnd) * rr * .36);
        c.drawArc(Rect.fromCenter(center: p, width: rr * (.35 + rnd.nextDouble() * .65), height: rr * (.10 + rnd.nextDouble() * .22)),
          rnd.nextDouble() * math.pi, .35 + rnd.nextDouble() * .8, false,
          Paint()..style = PaintingStyle.stroke..strokeWidth = .42..color = Colors.white.withValues(alpha: active ? .065 : .028));
      }
    }

    // Polar caps / high-latitude ice-like layers, deliberately abstract rather than Earth-like.
    final capPaint = Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [Colors.white.withValues(alpha: .11), Colors.white.withValues(alpha: .025), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: rad));
    c.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy - rad * .82), width: rad * 1.15, height: rad * .34), capPaint);
    c.drawOval(Rect.fromCenter(center: Offset(center.dx, center.dy + rad * .82), width: rad * .95, height: rad * .28), capPaint);

    // Micro terrain and crater-like features.
    for (var i = 0; i < 170; i++) {
      final x = center.dx + _noise(rnd) * rad * .92;
      final y = center.dy + _noise(rnd) * rad * .92;
      final rr = .18 + rnd.nextDouble() * 1.35;
      final alpha = .012 + rnd.nextDouble() * .04;
      c.drawCircle(Offset(x, y), rr, Paint()..color = Colors.white.withValues(alpha: alpha));
      if (i % 11 == 0) c.drawCircle(Offset(x, y), rr * 2.1, Paint()..style = PaintingStyle.stroke..strokeWidth = .25..color = Colors.black.withValues(alpha: .035));
    }

    // Thin cloud/debris bands that wrap visually around the sphere.
    for (var cloud = 0; cloud < 12; cloud++) {
      final y = center.dy + (cloud - 6) * rad * .115 + math.sin(t * math.pi * 2 + cloud) * rad * .012;
      final start = math.pi * (.08 + rnd.nextDouble() * .35);
      c.drawArc(Rect.fromCenter(center: Offset(center.dx, y), width: rad * (1.35 + rnd.nextDouble() * .35), height: rad * (.12 + rnd.nextDouble() * .11)),
        start, math.pi * (.28 + rnd.nextDouble() * .36), false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = .55 + rnd.nextDouble() * .65..color = Colors.white.withValues(alpha: .025 + rnd.nextDouble() * .045));
    }
    c.restore();

    // Physically readable spherical lighting and terminator.
    final shade = Paint()..shader = const RadialGradient(center: Alignment(-.46, -.48), radius: .76,
      colors: [Colors.transparent, Color(0x14000000), Color(0x70000000), Color(0xE0000000)]).createShader(Offset.zero & s);
    c.drawCircle(center, rad, shade);
    final terminator = Paint()..shader = const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
      colors: [Colors.transparent, Color(0x08000000), Color(0x55000000)]).createShader(Offset.zero & s);
    c.drawCircle(center, rad, terminator);

    // Atmospheric shell and a moving high-altitude light trace.
    final atmosphere = Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 3.0 : 1.45..color = Colors.white.withValues(alpha: active ? .19 : .075);
    c.drawCircle(center, rad + 1.4, atmosphere);
    c.drawArc(Rect.fromCircle(center: center, radius: rad + 3.0), math.pi * 1.02, math.pi * .62, false,
      Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 2.2 : 1.0..color = const Color(0x467F70B0));
    final sweep = t * math.pi * 2 + seed;
    c.drawArc(Rect.fromCircle(center: center, radius: rad + 2.0), sweep, math.pi * .18, false,
      Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 1.6 : .7..color = Colors.white.withValues(alpha: active ? .10 : .035));
    final glow = Paint()..shader = RadialGradient(colors: [const Color(0x1D8E83A8), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(center.dx - rad * .34, center.dy - rad * .35), radius: rad * .72));
    c.drawCircle(Offset(center.dx - rad * .34, center.dy - rad * .35), rad * .72, glow);
  }
  @override bool shouldRepaint(covariant _PlanetPainter old) => old.seed != seed || old.active != active || old.t != t;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

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

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> {
  GalaxyWorldKind? selected;
  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    GalaxyWorld? current;
    for (final world in widget.worlds) {
      if (world.kind == selected) { current = world; break; }
    }
    return Scaffold(
      backgroundColor: const Color(0xFF010106),
      body: Stack(fit: StackFit.expand, children: [
        const _GalaxyBackground(),
        _GalaxyPlanets(worlds: widget.worlds, compact: compact, selected: selected,
          onSelect: (world) => setState(() => selected = selected == world.kind ? null : world.kind)),
        Positioned(left: compact ? 18 : 34, top: compact ? 18 : 28,
          child: const Text('DARKESTWORLD', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300))),
        if (current != null)
          Positioned(right: compact ? 14 : 34, bottom: compact ? 14 : 34, width: compact ? 260 : 340,
            child: _SelectionPanel(world: current, onClose: () => setState(() => selected = null), onEnter: () => widget.onWorldTap?.call(current!))),
      ]),
    );
  }
}

class _GalaxyBackground extends StatelessWidget {
  const _GalaxyBackground();
  @override Widget build(BuildContext context) => CustomPaint(painter: _GalaxyBackgroundPainter());
}

class _GalaxyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(
      center: Alignment(0, -.10), radius: 1.18,
      colors: [Color(0xFF1A1728), Color(0xFF080811), Color(0xFF010105)],
    ).createShader(rect));
    final r = math.Random(17);
    for (var i = 0; i < 260; i++) {
      canvas.drawCircle(Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        .15 + r.nextDouble() * .75,
        Paint()..color = Colors.white.withValues(alpha: .035 + r.nextDouble() * .13));
    }
    final haze = Paint()..shader = RadialGradient(
      colors: [const Color(0xFF6D4B8A).withValues(alpha: .075), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width * .52, size.height * .47), radius: size.width * .50));
    canvas.drawCircle(Offset(size.width * .52, size.height * .47), size.width * .50, haze);
  }
  @override bool shouldRepaint(covariant _GalaxyBackgroundPainter oldDelegate) => false;
}

class _GalaxyPlanets extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final bool compact;
  final GalaxyWorldKind? selected;
  final ValueChanged<GalaxyWorld> onSelect;
  const _GalaxyPlanets({required this.worlds, required this.compact, required this.selected, required this.onSelect});

  static const positions = <GalaxyWorldKind, Offset>{
    GalaxyWorldKind.vegeta: Offset(.50, .53), GalaxyWorldKind.game: Offset(.79, .25),
    GalaxyWorldKind.identity: Offset(.19, .34), GalaxyWorldKind.cinema: Offset(.84, .59),
    GalaxyWorldKind.creation: Offset(.21, .74), GalaxyWorldKind.music: Offset(.61, .82),
    GalaxyWorldKind.family: Offset(.39, .17), GalaxyWorldKind.archive: Offset(.08, .56),
    GalaxyWorldKind.comingSoon: Offset(.91, .80),
  };

  static const factors = <GalaxyWorldKind, double>{
    GalaxyWorldKind.vegeta: .40, GalaxyWorldKind.game: .25, GalaxyWorldKind.identity: .205,
    GalaxyWorldKind.cinema: .19, GalaxyWorldKind.creation: .18, GalaxyWorldKind.music: .16,
    GalaxyWorldKind.family: .145, GalaxyWorldKind.archive: .115, GalaxyWorldKind.comingSoon: .09,
  };

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.sizeOf(context);
    final base = math.min(s.width, s.height);
    return Stack(fit: StackFit.expand, children: [
      for (final world in worlds.where((w) => positions.containsKey(w.kind)))
        Positioned(left: s.width * positions[world.kind]!.dx, top: s.height * positions[world.kind]!.dy,
          child: Transform.translate(
            offset: Offset(-_size(base, world.kind) / 2, -_size(base, world.kind) / 2),
            child: _Planet(world: world, size: _size(base, world.kind), muted: selected != null && selected != world.kind, onTap: () => onSelect(world)),
          )),
    ]);
  }

  double _size(double base, GalaxyWorldKind kind) => math.max(76, base * (factors[kind] ?? .1));
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool muted;
  final VoidCallback onTap;
  const _Planet({required this.world, required this.size, required this.muted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = world.kind == GalaxyWorldKind.vegeta ? const Color(0xFF9D7AC6) : const Color(0xFF7185A6);
    return GestureDetector(onTap: onTap, child: Opacity(opacity: muted ? .18 : 1,
      child: SizedBox(width: size, child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: size, height: size, child: CustomPaint(painter: _WorldPlanetPainter(seed: world.kind.index + 21, accent: accent))),
        const SizedBox(height: 7),
        Text(world.title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white70, fontSize: world.kind == GalaxyWorldKind.vegeta ? 11 : 8,
            letterSpacing: world.kind == GalaxyWorldKind.vegeta ? 3 : 1.7)),
      ]))));
  }
}

class _WorldPlanetPainter extends CustomPainter {
  final int seed;
  final Color accent;
  const _WorldPlanetPainter({required this.seed, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * .5, size.height * .5);
    final r = size.shortestSide * .438;
    final sphere = Rect.fromCircle(center: c, radius: r);
    final rnd = math.Random(seed * 137);

    // Layered atmosphere: broad halo + thin lit rim.
    canvas.drawCircle(c, r * 1.42, Paint()..shader = RadialGradient(
      colors: [accent.withValues(alpha: .22), accent.withValues(alpha: .08), Colors.transparent],
      stops: const [.0, .48, 1],
    ).createShader(Rect.fromCircle(center: c, radius: r * 1.42)));
    canvas.drawCircle(c, r * 1.035, Paint()..shader = RadialGradient(
      center: const Alignment(-.50, -.55), radius: 1.10,
      colors: [const Color(0xFFD0C5B7), accent.withValues(alpha: .74), const Color(0xFF666773), const Color(0xFF252833), const Color(0xFF04060B)],
      stops: const [0, .16, .40, .72, 1],
    ).createShader(sphere));

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Three large continuous continents. Smooth curves make them read as terrain,
    // not as painted blobs. Their shape and scale are deliberately different per world.
    final continentColors = [
      accent.withValues(alpha: .48),
      const Color(0xFF9A876B).withValues(alpha: .31),
      const Color(0xFF61716B).withValues(alpha: .28),
    ];
    final centers = [
      c + Offset(-r * .20, -r * .12),
      c + Offset(r * .18, r * .04),
      c + Offset(-r * .02, r * .30),
    ];
    final widths = [r * .92, r * .74, r * .58];
    final heights = [r * .38, r * .34, r * .25];
    final rotations = [-.18, .35, -.52];

    for (var i = 0; i < 3; i++) {
      final path = _smoothLand(centers[i], widths[i], heights[i], rotations[i], seed + i * 31);
      canvas.drawPath(path, Paint()..color = continentColors[i]);
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .009..color = Colors.white.withValues(alpha: .085));

      // Nested terrain contours remain inside the same landmass.
      for (var q = 1; q <= 5; q++) {
        final scale = 1 - q * .11;
        final inner = _smoothLand(
          centers[i] + Offset(-r * .012 * q, r * .008 * q),
          widths[i] * scale, heights[i] * scale, rotations[i], seed + i * 31 + q * 7,
        );
        canvas.drawPath(inner, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .004
          ..color = Colors.white.withValues(alpha: .020 + (5 - q) * .004));
      }
    }

    // Fine topographic traces across the visible hemisphere.
    for (var i = 0; i < 9; i++) {
      final y = c.dy - r * .62 + i * r * .155;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(c.dx - r * .03, y), width: r * 1.70, height: r * .16),
        math.pi * .08, math.pi * .84, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = r * .010..color = Colors.white.withValues(alpha: .014),
      );
    }

    // Sparse mineral/surface texture; deliberately subtle and non-Earth-like.
    for (var i = 0; i < 95; i++) {
      final x = c.dx + (rnd.nextDouble() * 2 - 1) * r * .87;
      final y = c.dy + (rnd.nextDouble() * 2 - 1) * r * .78;
      canvas.drawCircle(Offset(x, y), r * (.001 + rnd.nextDouble() * .0045),
        Paint()..color = Colors.white.withValues(alpha: .012 + rnd.nextDouble() * .035));
    }

    // A faint atmospheric veil on the day side.
    for (var i = 0; i < 4; i++) {
      final veil = Rect.fromCircle(center: c + Offset(-r * .13, -r * .12), radius: r * (.72 + i * .055));
      canvas.drawArc(veil, math.pi * .92, math.pi * .60, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = r * .018..color = Colors.white.withValues(alpha: .012));
    }
    canvas.restore();

    // Deep terminator and a soft outer night-side falloff.
    final shadowCenter = c + Offset(r * .57, r * .10);
    canvas.drawCircle(shadowCenter, r * .92, Paint()..shader = RadialGradient(
      colors: [Colors.transparent, Colors.black.withValues(alpha: .80)],
      stops: const [.31, 1],
    ).createShader(Rect.fromCircle(center: shadowCenter, radius: r * .92)));

    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.008), math.pi * .59, math.pi * .90, false,
      Paint()..style = PaintingStyle.stroke..strokeWidth = r * .012..color = Colors.white.withValues(alpha: .24));
    canvas.drawArc(Rect.fromCircle(center: c + Offset(-r * .03, -r * .03), radius: r * .95), math.pi * 1.01, math.pi * .43, false,
      Paint()..style = PaintingStyle.stroke..strokeWidth = r * .030..color = Colors.white.withValues(alpha: .032));
  }

  Path _smoothLand(Offset center, double width, double height, double rotation, int localSeed) {
    final rnd = math.Random(localSeed * 17);
    const n = 12;
    final points = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2;
      final wave = math.sin(a * 2 + localSeed) * .10 + math.sin(a * 3.7 + localSeed * .23) * .065;
      final radius = .84 + wave + rnd.nextDouble() * .08;
      final x = math.cos(a) * width * .5 * radius;
      final y = math.sin(a) * height * .5 * (.92 + .08 * math.sin(a * 2.5 + localSeed));
      final xr = x * math.cos(rotation) - y * math.sin(rotation);
      final yr = x * math.sin(rotation) + y * math.cos(rotation);
      points.add(Offset(center.dx + xr, center.dy + yr));
    }
    final p = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < n; i++) {
      final a = points[i];
      final b = points[(i + 1) % n];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      p.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
    }
    p.close();
    return p;
  }

  @override bool shouldRepaint(covariant _WorldPlanetPainter oldDelegate) => false;
}

class _SelectionPanel extends StatelessWidget {
  final GalaxyWorld world;
  final VoidCallback onClose;
  final VoidCallback onEnter;
  const _SelectionPanel({required this.world, required this.onClose, required this.onEnter});

  @override
  Widget build(BuildContext context) => Material(color: Colors.transparent, child: Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xE6090914), border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)),
      const SizedBox(height: 8), Text(world.description, style: const TextStyle(color: Colors.white54)),
      const SizedBox(height: 14), Row(children: [
        TextButton(onPressed: onClose, child: const Text('Sluiten')), const Spacer(),
        ElevatedButton(onPressed: onEnter, child: const Text('Openen')),
      ]),
    ]),
  ));
}

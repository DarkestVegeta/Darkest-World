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

    // Deep atmospheric halo, then a softly illuminated solid world.
    canvas.drawCircle(c, r * 1.34, Paint()..shader = RadialGradient(
      colors: [accent.withValues(alpha: .30), accent.withValues(alpha: .10), Colors.transparent],
      stops: const [.0, .48, 1],
    ).createShader(Rect.fromCircle(center: c, radius: r * 1.34)));
    canvas.drawCircle(c, r * 1.035, Paint()..shader = RadialGradient(
      center: const Alignment(-.46, -.55), radius: 1.08,
      colors: [accent.withValues(alpha: .32), const Color(0xFFB9B1A8), const Color(0xFF676773), const Color(0xFF20232D), const Color(0xFF05070C)],
      stops: const [0, .13, .38, .72, 1],
    ).createShader(sphere));

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    // Large, coherent landmasses. They are deliberately few and irregular so the
    // surface reads as a photographed world instead of a ball covered in dots.
    final landColors = [
      accent.withValues(alpha: .46),
      const Color(0xFFB49A76).withValues(alpha: .29),
      const Color(0xFF63776E).withValues(alpha: .30),
    ];
    for (var i = 0; i < 3; i++) {
      final a = i * 2.08 + rnd.nextDouble() * .22;
      final center = c + Offset(math.cos(a) * r * .17, math.sin(a) * r * .14);
      final w = r * (.76 + rnd.nextDouble() * .15);
      final h = r * (.28 + rnd.nextDouble() * .10);
      final rot = a * .30 + rnd.nextDouble() * .20;
      final path = _organicLand(center, w, h, rot, rnd, 32);
      canvas.drawPath(path, Paint()..color = landColors[i]);
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .008..color = Colors.white.withValues(alpha: .095));

      // Topographic rings follow the same continent instead of becoming random blobs.
      for (var q = 1; q <= 5; q++) {
        final scale = 1 - q * .105;
        final inner = _organicLand(
          center + Offset(-r * .010 * q, r * .008 * q),
          w * scale, h * scale, rot, rnd, 32,
        );
        canvas.drawPath(inner, Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .0045
          ..color = Colors.white.withValues(alpha: .025 + (5 - q) * .004));
      }
    }

    // Broad, very faint atmospheric/cloud bands.
    for (var i = 0; i < 6; i++) {
      final y = c.dy - r * .55 + i * r * .21;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(c.dx + r * .03, y), width: r * 1.72, height: r * .20),
        math.pi * .08, math.pi * .84, false,
        Paint()..style = PaintingStyle.stroke..strokeWidth = r * .017..color = Colors.white.withValues(alpha: .018),
      );
    }

    // Tiny surface texture only. No obvious craters or Earth-like blue/green noise.
    for (var i = 0; i < 70; i++) {
      final x = c.dx + (rnd.nextDouble() * 2 - 1) * r * .86;
      final y = c.dy + (rnd.nextDouble() * 2 - 1) * r * .76;
      canvas.drawCircle(Offset(x, y), r * (.001 + rnd.nextDouble() * .005),
        Paint()..color = Colors.white.withValues(alpha: .018 + rnd.nextDouble() * .035));
    }
    canvas.restore();

    // Strong asymmetric terminator makes the sphere read as a world in space.
    final shadowCenter = c + Offset(r * .54, r * .10);
    canvas.drawCircle(shadowCenter, r * .90, Paint()..shader = RadialGradient(
      colors: [Colors.transparent, Colors.black.withValues(alpha: .77)],
      stops: const [.35, 1],
    ).createShader(Rect.fromCircle(center: shadowCenter, radius: r * .90)));

    // Thin atmospheric rim and a soft light-catching crescent.
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.008), math.pi * .60, math.pi * .88, false,
      Paint()..style = PaintingStyle.stroke..strokeWidth = r * .010..color = Colors.white.withValues(alpha: .22));
    canvas.drawArc(Rect.fromCircle(center: c + Offset(-r * .035, -r * .035), radius: r * .94), math.pi * 1.02, math.pi * .42, false,
      Paint()..style = PaintingStyle.stroke..strokeWidth = r * .032..color = Colors.white.withValues(alpha: .035));
  }

  Path _organicLand(Offset center, double width, double height, double rotation, math.Random rnd, int points) {
    final p = Path();
    final radii = <double>[];
    for (var i = 0; i < points; i++) {
      // Smooth-ish low-frequency variation rather than independent random spikes.
      final wave = math.sin(i * .73 + seed) * .10 + math.sin(i * .31 + seed * .7) * .08;
      radii.add(.86 + wave + rnd.nextDouble() * .13);
    }
    for (var i = 0; i < points; i++) {
      final a = i / points * math.pi * 2;
      final wobble = radii[i];
      final x = math.cos(a) * width * .5 * wobble;
      final y = math.sin(a) * height * .5 * (.90 + .10 * math.sin(a * 3 + seed));
      final xr = x * math.cos(rotation) - y * math.sin(rotation);
      final yr = x * math.sin(rotation) + y * math.cos(rotation);
      final pt = Offset(center.dx + xr, center.dy + yr);
      if (i == 0) { p.moveTo(pt.dx, pt.dy); } else { p.lineTo(pt.dx, pt.dy); }
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

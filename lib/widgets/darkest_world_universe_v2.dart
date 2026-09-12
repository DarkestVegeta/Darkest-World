import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'darkest_world_universe.dart';

class DarkestWorldUniverseV2 extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;
  const DarkestWorldUniverseV2({super.key, required this.worlds, this.onWorldTap});

  @override
  State<DarkestWorldUniverseV2> createState() => _DarkestWorldUniverseV2State();
}

class _DarkestWorldUniverseV2State extends State<DarkestWorldUniverseV2>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  )..repeat();
  GalaxyWorldKind? selected;

  static const positions = <GalaxyWorldKind, Offset>{
    GalaxyWorldKind.vegeta: Offset(.50, .53),
    GalaxyWorldKind.game: Offset(.78, .25),
    GalaxyWorldKind.identity: Offset(.19, .34),
    GalaxyWorldKind.cinema: Offset(.84, .59),
    GalaxyWorldKind.creation: Offset(.21, .74),
    GalaxyWorldKind.music: Offset(.61, .82),
    GalaxyWorldKind.family: Offset(.39, .17),
    GalaxyWorldKind.archive: Offset(.08, .56),
    GalaxyWorldKind.comingSoon: Offset(.91, .80),
  };

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 760;
    final current = selected == null
        ? null
        : widget.worlds.cast<GalaxyWorld?>().firstWhere(
            (w) => w?.kind == selected,
            orElse: () => null,
          );

    return Scaffold(
      backgroundColor: const Color(0xFF010105),
      body: AnimatedBuilder(
        animation: _clock,
        builder: (context, _) => Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: _UniversePainter(_clock.value)),
            _routes(compact),
            _planets(compact),
            Positioned(
              left: compact ? 18 : 34,
              top: compact ? 18 : 28,
              child: _Header(compact: compact),
            ),
            if (current != null)
              Positioned(
                right: compact ? 14 : 34,
                bottom: compact ? 14 : 34,
                width: compact ? 285 : 365,
                child: _WorldPanel(
                  world: current,
                  onClose: () => setState(() => selected = null),
                  onEnter: () => widget.onWorldTap?.call(current),
                ),
              ),
            Positioned(
              left: compact ? 18 : 34,
              bottom: compact ? 18 : 34,
              child: _Legend(compact: compact, selected: selected),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routes(bool compact) => IgnorePointer(
        child: CustomPaint(
          painter: _RoutePainter(
            phase: _clock.value,
            selected: selected,
            compact: compact,
          ),
        ),
      );

  Widget _planets(bool compact) {
    final base = math.min(MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height);
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final world in widget.worlds.where((w) => positions.containsKey(w.kind)))
          Positioned(
            left: MediaQuery.sizeOf(context).width * positions[world.kind]!.dx,
            top: MediaQuery.sizeOf(context).height * positions[world.kind]!.dy,
            child: Transform.translate(
              offset: Offset(-_size(base, world.kind) / 2, -_size(base, world.kind) / 2),
              child: _WorldNode(
                world: world,
                size: _size(base, world.kind),
                selected: selected == world.kind,
                muted: selected != null && selected != world.kind,
                phase: _clock.value,
                onTap: () => setState(() => selected = selected == world.kind ? null : world.kind),
              ),
            ),
          ),
      ],
    );
  }

  double _size(double base, GalaxyWorldKind kind) {
    const factors = <GalaxyWorldKind, double>{
      GalaxyWorldKind.vegeta: .40,
      GalaxyWorldKind.game: .25,
      GalaxyWorldKind.identity: .205,
      GalaxyWorldKind.cinema: .19,
      GalaxyWorldKind.creation: .18,
      GalaxyWorldKind.music: .16,
      GalaxyWorldKind.family: .145,
      GalaxyWorldKind.archive: .115,
      GalaxyWorldKind.comingSoon: .09,
    };
    return math.max(76, base * (factors[kind] ?? .1));
  }
}

class _Header extends StatelessWidget {
  final bool compact;
  const _Header({required this.compact});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DARKESTWORLD',
            style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 7),
          Text(
            'LIVING WORLDS  /  ${compact ? 'ORBIT VIEW' : 'GALAXY VIEW'}',
            style: const TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 2.4),
          ),
        ],
      );
}

class _WorldNode extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool selected;
  final bool muted;
  final double phase;
  final VoidCallback onTap;
  const _WorldNode({required this.world, required this.size, required this.selected, required this.muted, required this.phase, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = world.kind == GalaxyWorldKind.vegeta ? const Color(0xFF9D7AC6) : const Color(0xFF7185A6);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        opacity: muted ? .16 : 1,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: selected ? 1.10 : 1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
          child: SizedBox(
            width: size,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CustomPaint(
                    painter: _PlanetPainter(
                      seed: world.kind.index + 21,
                      accent: accent,
                      selected: selected,
                      kind: world.kind,
                      phase: phase,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  world.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: world.kind == GalaxyWorldKind.vegeta ? 11 : 8,
                    letterSpacing: world.kind == GalaxyWorldKind.vegeta ? 3 : 1.7,
                    fontWeight: selected ? FontWeight.w400 : FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  final int seed;
  final Color accent;
  final bool selected;
  final GalaxyWorldKind kind;
  final double phase;
  const _PlanetPainter({required this.seed, required this.accent, required this.selected, required this.kind, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * .5, size.height * .5);
    final r = size.shortestSide * .438;
    final sphere = Rect.fromCircle(center: c, radius: r);
    final rnd = math.Random(seed * 137);
    final pulse = .5 + .5 * math.sin(phase * math.pi * 2 + seed);

    canvas.drawCircle(
      c,
      r * (1.34 + pulse * .08),
      Paint()..shader = RadialGradient(colors: [accent.withValues(alpha: selected ? .30 : .17), accent.withValues(alpha: .06), Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r * 1.5)),
    );
    canvas.drawCircle(
      c,
      r * 1.055,
      Paint()..shader = RadialGradient(center: const Alignment(-.52, -.58), radius: 1.08, colors: [const Color(0xFFE0D4C3), accent.withValues(alpha: .78), const Color(0xFF6C7075), const Color(0xFF292C34), const Color(0xFF03050A)], stops: const [0, .13, .37, .70, 1]).createShader(sphere),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));
    final terrain = [accent.withValues(alpha: .43), const Color(0xFF9C886A).withValues(alpha: .30), const Color(0xFF64736D).withValues(alpha: .27)];
    final centers = [c + Offset(-r * .20, -r * .10), c + Offset(r * .20, r * .02), c + Offset(-r * .04, r * .29)];
    final widths = [r * .96, r * .73, r * .59];
    final heights = [r * .40, r * .33, r * .25];
    final rotations = [-.18, .34, -.52];
    for (var i = 0; i < 3; i++) {
      final land = _land(centers[i], widths[i], heights[i], rotations[i], seed + i * 31);
      canvas.drawPath(land, Paint()..color = terrain[i]);
      for (var q = 1; q <= 6; q++) {
        final scale = 1 - q * .105;
        final inner = _land(centers[i] + Offset(-r * .012 * q, r * .008 * q), widths[i] * scale, heights[i] * scale, rotations[i], seed + i * 31 + q * 7);
        canvas.drawPath(inner, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .004..color = Colors.white.withValues(alpha: .018 + (6 - q) * .004));
      }
    }
    if (kind == GalaxyWorldKind.game) {
      final borders = Paint()..style = PaintingStyle.stroke..strokeWidth = r * .006..color = Colors.white.withValues(alpha: selected ? .11 : .05);
      canvas.drawArc(Rect.fromCenter(center: c + Offset(-r * .05, -r * .10), width: r * 1.05, height: r * .55), math.pi * .98, math.pi * .58, false, borders);
      canvas.drawArc(Rect.fromCenter(center: c + Offset(r * .13, r * .09), width: r * .82, height: r * .72), math.pi * .08, math.pi * .62, false, borders);
    }
    for (var i = 0; i < 120; i++) {
      final x = c.dx + (rnd.nextDouble() * 2 - 1) * r * .88;
      final y = c.dy + (rnd.nextDouble() * 2 - 1) * r * .82;
      canvas.drawCircle(Offset(x, y), r * (.0008 + rnd.nextDouble() * .0048), Paint()..color = Colors.white.withValues(alpha: .008 + rnd.nextDouble() * .028));
    }
    canvas.restore();

    final shadow = c + Offset(r * .57, r * .09);
    canvas.drawCircle(shadow, r * .94, Paint()..shader = RadialGradient(colors: [Colors.transparent, Colors.black.withValues(alpha: .82)], stops: const [.28, 1]).createShader(Rect.fromCircle(center: shadow, radius: r * .94)));
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * 1.008), math.pi * .59, math.pi * .91, false, Paint()..style = PaintingStyle.stroke..strokeWidth = r * .012..color = Colors.white.withValues(alpha: selected ? .34 : .26));
  }

  Path _land(Offset center, double width, double height, double rotation, int localSeed) {
    final rnd = math.Random(localSeed * 17);
    const n = 14;
    final points = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = i / n * math.pi * 2;
      final wave = math.sin(a * 2 + localSeed) * .105 + math.sin(a * 3.7 + localSeed * .23) * .065;
      final radius = .82 + wave + rnd.nextDouble() * .09;
      final x = math.cos(a) * width * .5 * radius;
      final y = math.sin(a) * height * .5 * radius;
      points.add(Offset(center.dx + x * math.cos(rotation) - y * math.sin(rotation), center.dy + x * math.sin(rotation) + y * math.cos(rotation)));
    }
    final p = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < n; i++) {
      final a = points[i], b = points[(i + 1) % n];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      p.quadraticBezierTo(a.dx, a.dy, mid.dx, mid.dy);
    }
    return p..close();
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter old) => old.phase != phase || old.selected != selected || old.kind != kind;
}

class _RoutePainter extends CustomPainter {
  final double phase;
  final GalaxyWorldKind? selected;
  final bool compact;
  const _RoutePainter({required this.phase, required this.selected, required this.compact});

  static const positions = <GalaxyWorldKind, Offset>{
    GalaxyWorldKind.vegeta: Offset(.50, .53), GalaxyWorldKind.game: Offset(.78, .25), GalaxyWorldKind.identity: Offset(.19, .34),
    GalaxyWorldKind.cinema: Offset(.84, .59), GalaxyWorldKind.creation: Offset(.21, .74), GalaxyWorldKind.music: Offset(.61, .82),
    GalaxyWorldKind.family: Offset(.39, .17), GalaxyWorldKind.archive: Offset(.08, .56), GalaxyWorldKind.comingSoon: Offset(.91, .80),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width * .5, size.height * .53);
    final routes = [GalaxyWorldKind.game, GalaxyWorldKind.identity, GalaxyWorldKind.music, GalaxyWorldKind.cinema, GalaxyWorldKind.creation, GalaxyWorldKind.family];
    for (final kind in routes) {
      final p = Offset(size.width * positions[kind]!.dx, size.height * positions[kind]!.dy);
      final path = Path()..moveTo(c.dx, c.dy)..quadraticBezierTo((c.dx + p.dx) / 2, (c.dy + p.dy) / 2 + math.sin(kind.index) * 25, p.dx, p.dy);
      final active = selected == null || selected == kind;
      canvas.drawPath(path, Paint()..style = PaintingStyle.stroke..strokeWidth = selected == kind ? 1.4 : .65..color = Colors.white.withValues(alpha: active ? .12 : .025));
      final t = (phase + kind.index * .11) % 1;
      final dot = _pointOnQuadratic(c, Offset((c.dx + p.dx) / 2, (c.dy + p.dy) / 2 + math.sin(kind.index) * 25), p, t);
      canvas.drawCircle(dot, selected == kind ? 3.2 : 1.8, Paint()..color = Colors.white.withValues(alpha: active ? .45 : .08));
    }
    final ring = Rect.fromCircle(center: c, radius: math.min(size.width, size.height) * (compact ? .25 : .31));
    canvas.drawArc(ring, phase * math.pi * 2, math.pi * .38, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withValues(alpha: .055));
    canvas.drawArc(ring, phase * math.pi * 2 + math.pi, math.pi * .22, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = Colors.white.withValues(alpha: .035));
  }

  Offset _pointOnQuadratic(Offset a, Offset b, Offset c, double t) => Offset((1 - t) * (1 - t) * a.dx + 2 * (1 - t) * t * b.dx + t * t * c.dx, (1 - t) * (1 - t) * a.dy + 2 * (1 - t) * t * b.dy + t * t * c.dy);
  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.phase != phase || old.selected != selected || old.compact != compact;
}

class _UniversePainter extends CustomPainter {
  final double phase;
  const _UniversePainter(this.phase);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..shader = const RadialGradient(center: Alignment(0, -.1), radius: 1.18, colors: [Color(0xFF1A1728), Color(0xFF080811), Color(0xFF010105)]).createShader(rect));
    final r = math.Random(17);
    for (var i = 0; i < 320; i++) {
      final x = r.nextDouble() * size.width;
      final y = r.nextDouble() * size.height;
      final twinkle = .025 + .085 * (.5 + .5 * math.sin(phase * math.pi * 2 * (1 + (i % 4)) + i));
      canvas.drawCircle(Offset(x, y), .15 + r.nextDouble() * .72, Paint()..color = Colors.white.withValues(alpha: twinkle));
    }
    final haze = Paint()..shader = RadialGradient(colors: [const Color(0xFF6D4B8A).withValues(alpha: .07), Colors.transparent]).createShader(Rect.fromCircle(center: Offset(size.width * .52, size.height * .47), radius: size.width * .50));
    canvas.drawCircle(Offset(size.width * .52, size.height * .47), size.width * .50, haze);
  }
  @override
  bool shouldRepaint(covariant _UniversePainter old) => old.phase != phase;
}

class _Legend extends StatelessWidget {
  final bool compact;
  final GalaxyWorldKind? selected;
  const _Legend({required this.compact, required this.selected});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: .34), border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF9D7AC6))),
          const SizedBox(width: 8),
          Text(selected == null ? 'SELECT A WORLD' : 'WORLD SELECTED', style: const TextStyle(color: Colors.white38, fontSize: 8, letterSpacing: 1.7)),
          if (!compact) ...[const SizedBox(width: 14), const Text('•', style: TextStyle(color: Colors.white12)), const SizedBox(width: 14), const Text('ENTER', style: TextStyle(color: Colors.white24, fontSize: 8, letterSpacing: 1.4))],
        ]),
      );
}

class _WorldPanel extends StatelessWidget {
  final GalaxyWorld world;
  final VoidCallback onClose;
  final VoidCallback onEnter;
  const _WorldPanel({required this.world, required this.onClose, required this.onEnter});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xEA151321), Color(0xE8080912)]),
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 28, offset: Offset(0, 14))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [Expanded(child: Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2))), IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 17, color: Colors.white54))]),
            const SizedBox(height: 4),
            Container(height: 1, width: 42, color: Colors.white24),
            const SizedBox(height: 10),
            Text(world.description, style: const TextStyle(color: Colors.white54, height: 1.35)),
            const SizedBox(height: 14),
            Row(children: [TextButton(onPressed: onClose, child: const Text('Sluiten')), const Spacer(), ElevatedButton(onPressed: onEnter, child: const Text('Open world'))]),
          ]),
        ),
      );
}

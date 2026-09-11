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

  @override
  State<DarkestWorldUniverse> createState() => _DarkestWorldUniverseState();
}

class _DarkestWorldUniverseState extends State<DarkestWorldUniverse> {
  GalaxyWorldKind? selected;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 700;
    final current = selected == null
        ? null
        : widget.worlds.where((world) => world.kind == selected).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFF010106),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _GalaxyBackground(),
          _GalaxyPlanets(
            worlds: widget.worlds,
            compact: compact,
            selected: selected,
            onSelect: (world) => setState(
              () => selected = selected == world.kind ? null : world.kind,
            ),
          ),
          Positioned(
            left: compact ? 18 : 34,
            top: compact ? 18 : 28,
            child: const Text(
              'DARKESTWORLD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          if (current != null)
            Positioned(
              right: compact ? 14 : 34,
              bottom: compact ? 14 : 34,
              width: compact ? 260 : 340,
              child: _SelectionPanel(
                world: current,
                onClose: () => setState(() => selected = null),
                onEnter: () => widget.onWorldTap?.call(current),
              ),
            ),
        ],
      ),
    );
  }
}

class _GalaxyBackground extends StatelessWidget {
  const _GalaxyBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GalaxyBackgroundPainter());
}

class _GalaxyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.1),
          radius: 1.15,
          colors: [Color(0xFF17152A), Color(0xFF060710), Color(0xFF010105)],
        ).createShader(Offset.zero & size),
    );

    final random = math.Random(17);
    for (var i = 0; i < 190; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        .25 + random.nextDouble() * .85,
        Paint()..color = Colors.white.withValues(alpha: .10 + random.nextDouble() * .18),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyBackgroundPainter oldDelegate) => false;
}

class _GalaxyPlanets extends StatelessWidget {
  final List<GalaxyWorld> worlds;
  final bool compact;
  final GalaxyWorldKind? selected;
  final ValueChanged<GalaxyWorld> onSelect;
  const _GalaxyPlanets({required this.worlds, required this.compact, required this.selected, required this.onSelect});

  static const pos = <GalaxyWorldKind, Offset>{
    GalaxyWorldKind.vegeta: Offset(.50, .53),
    GalaxyWorldKind.game: Offset(.78, .25),
    GalaxyWorldKind.identity: Offset(.20, .34),
    GalaxyWorldKind.cinema: Offset(.84, .59),
    GalaxyWorldKind.creation: Offset(.22, .73),
    GalaxyWorldKind.music: Offset(.61, .81),
    GalaxyWorldKind.family: Offset(.39, .17),
    GalaxyWorldKind.archive: Offset(.09, .56),
    GalaxyWorldKind.comingSoon: Offset(.91, .80),
  };

  static const fac = <GalaxyWorldKind, double>{
    GalaxyWorldKind.vegeta: .34,
    GalaxyWorldKind.game: .205,
    GalaxyWorldKind.identity: .175,
    GalaxyWorldKind.cinema: .165,
    GalaxyWorldKind.creation: .155,
    GalaxyWorldKind.music: .14,
    GalaxyWorldKind.family: .125,
    GalaxyWorldKind.archive: .095,
    GalaxyWorldKind.comingSoon: .08,
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = math.min(size.width, size.height);

    return Stack(
      fit: StackFit.expand,
      children: [
        for (final world in worlds.where((world) => pos.containsKey(world.kind)))
          Positioned(
            left: size.width * pos[world.kind]!.dx,
            top: size.height * pos[world.kind]!.dy,
            child: Transform.translate(
              offset: Offset(-_size(base, world.kind) / 2, -_size(base, world.kind) / 2),
              child: _Planet(
                world: world,
                size: _size(base, world.kind),
                muted: selected != null && selected != world.kind,
                onTap: () => onSelect(world),
              ),
            ),
          ),
      ],
    );
  }

  double _size(double base, GalaxyWorldKind kind) => math.max(72, base * (fac[kind] ?? .1));
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool muted;
  final VoidCallback onTap;
  const _Planet({required this.world, required this.size, required this.muted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = world.kind == GalaxyWorldKind.vegeta
        ? const Color(0xFF9A7BC5)
        : const Color(0xFF657BA7);

    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: muted ? .28 : 1,
        child: SizedBox(
          width: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _WorldPlanetPainter(seed: world.kind.index + 21, accent: accent),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                world.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .86),
                  fontSize: world.kind == GalaxyWorldKind.vegeta ? 11 : 8,
                  letterSpacing: world.kind == GalaxyWorldKind.vegeta ? 3 : 1.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldPlanetPainter extends CustomPainter {
  final int seed;
  final Color accent;
  const _WorldPlanetPainter({required this.seed, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * .455;
    final sphere = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius * 1.18,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: .30), accent.withValues(alpha: .08), Colors.transparent],
          stops: const [.0, .48, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.18)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.38, -.46),
          radius: 1.08,
          colors: [Color(0xFF8B98B0), Color(0xFF3C4C63), Color(0xFF111722), Color(0xFF05070C)],
          stops: [.0, .38, .72, 1],
        ).createShader(sphere),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));

    final random = math.Random(seed * 91);
    final terrain = <Color>[
      accent.withValues(alpha: .16),
      const Color(0xFF8B806E).withValues(alpha: .13),
      const Color(0xFF536E67).withValues(alpha: .13),
      const Color(0xFF262E3C).withValues(alpha: .22),
    ];

    for (var i = 0; i < 9; i++) {
      final x = center.dx + (random.nextDouble() * 2 - 1) * radius * .62;
      final y = center.dy + (random.nextDouble() * 2 - 1) * radius * .57;
      final w = radius * (.18 + random.nextDouble() * .48);
      final h = radius * (.07 + random.nextDouble() * .22);
      final path = Path();
      final points = 8;
      for (var p = 0; p <= points; p++) {
        final a = p / points * math.pi * 2;
        final wobble = .76 + random.nextDouble() * .30;
        final px = x + math.cos(a) * w * .5 * wobble;
        final py = y + math.sin(a) * h * .5 * wobble;
        if (p == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, Paint()..color = terrain[i % terrain.length]);
    }

    for (var i = 0; i < 18; i++) {
      final x = center.dx + (random.nextDouble() * 2 - 1) * radius * .72;
      final y = center.dy + (random.nextDouble() * 2 - 1) * radius * .66;
      final rr = radius * (.008 + random.nextDouble() * .035);
      canvas.drawCircle(x: x, y: y, rr, Paint()..color = Colors.white.withValues(alpha: .025));
    }

    canvas.restore();

    canvas.drawCircle(
      center + Offset(radius * .40, radius * .10),
      radius * .82,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: .56)],
        ).createShader(Rect.fromCircle(center: center + Offset(radius * .40, radius * .10), radius: radius * .82)),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 1.012),
      math.pi * .66,
      math.pi * .78,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Colors.white.withValues(alpha: .22),
    );
  }

  @override
  bool shouldRepaint(covariant _WorldPlanetPainter oldDelegate) => false;
}

class _SelectionPanel extends StatelessWidget {
  final GalaxyWorld world;
  final VoidCallback onClose;
  final VoidCallback onEnter;
  const _SelectionPanel({required this.world, required this.onClose, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xE6090914),
          border: Border.all(color: Colors.white.withValues(alpha: .12)),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(world.description, style: TextStyle(color: Colors.white.withValues(alpha: .68))),
            const SizedBox(height: 14),
            Row(
              children: [
                TextButton(onPressed: onClose, child: const Text('Sluiten')),
                const Spacer(),
                ElevatedButton(onPressed: onEnter, child: const Text('Openen')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

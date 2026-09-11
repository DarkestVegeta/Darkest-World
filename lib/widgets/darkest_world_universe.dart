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
    GalaxyWorld? current;
    if (selected != null) {
      for (final world in widget.worlds) {
        if (world.kind == selected) {
          current = world;
          break;
        }
      }
    }

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
            onSelect: (world) => setState(() {
              selected = selected == world.kind ? null : world.kind;
            }),
          ),
          Positioned(
            left: compact ? 18 : 34,
            top: compact ? 18 : 28,
            child: const Text(
              'DARKESTWORLD',
              style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 5, fontWeight: FontWeight.w300),
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
                onEnter: () => widget.onWorldTap?.call(current!),
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
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -0.1),
          radius: 1.15,
          colors: [Color(0xFF18152B), Color(0xFF070711), Color(0xFF010105)],
        ).createShader(rect),
    );

    final random = math.Random(17);
    for (var i = 0; i < 210; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
        0.2 + random.nextDouble() * 0.8,
        Paint()..color = Colors.white.withValues(alpha: 0.07 + random.nextDouble() * 0.16),
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

  static const positions = <GalaxyWorldKind, Offset>{
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

  static const factors = <GalaxyWorldKind, double>{
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
        for (final world in worlds.where((w) => positions.containsKey(w.kind)))
          Positioned(
            left: size.width * positions[world.kind]!.dx,
            top: size.height * positions[world.kind]!.dy,
            child: Transform.translate(
              offset: Offset(-_planetSize(base, world.kind) / 2, -_planetSize(base, world.kind) / 2),
              child: _Planet(
                world: world,
                size: _planetSize(base, world.kind),
                muted: selected != null && selected != world.kind,
                onTap: () => onSelect(world),
              ),
            ),
          ),
      ],
    );
  }

  double _planetSize(double base, GalaxyWorldKind kind) => math.max(72, base * (factors[kind] ?? .1));
}

class _Planet extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool muted;
  final VoidCallback onTap;

  const _Planet({required this.world, required this.size, required this.muted, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final accent = world.kind == GalaxyWorldKind.vegeta ? const Color(0xFF9C78C7) : const Color(0xFF687EA9);
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: muted ? .25 : 1,
        child: SizedBox(
          width: size,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: size, height: size, child: CustomPaint(painter: _WorldPlanetPainter(seed: world.kind.index + 21, accent: accent))),
              const SizedBox(height: 7),
              Text(
                world.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white70, fontSize: world.kind == GalaxyWorldKind.vegeta ? 11 : 8, letterSpacing: world.kind == GalaxyWorldKind.vegeta ? 3 : 1.7),
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
      radius * 1.22,
      Paint()
        ..shader = RadialGradient(
          colors: [accent.withValues(alpha: .32), accent.withValues(alpha: .09), Colors.transparent],
          stops: const [0, .48, 1],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 1.22)),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.42, -.52),
          radius: 1.12,
          colors: [Color(0xFFA1A5AD), Color(0xFF596273), Color(0xFF202735), Color(0xFF06080D)],
          stops: [.0, .34, .68, 1],
        ).createShader(sphere),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(sphere));
    final random = math.Random(seed * 137);
    final terrain = [
      accent.withValues(alpha: .34),
      const Color(0xFF918774).withValues(alpha: .23),
      const Color(0xFF526A62).withValues(alpha: .22),
      const Color(0xFF303848).withValues(alpha: .28),
    ];

    for (var i = 0; i < 7; i++) {
      final x = center.dx + (random.nextDouble() * 2 - 1) * radius * .52;
      final y = center.dy + (random.nextDouble() * 2 - 1) * radius * .50;
      final width = radius * (.25 + random.nextDouble() * .55);
      final height = radius * (.10 + random.nextDouble() * .25);
      final path = Path();
      for (var j = 0; j < 13; j++) {
        final angle = j / 12 * math.pi * 2;
        final wobble = .72 + random.nextDouble() * .48;
        final px = x + math.cos(angle) * width * .5 * wobble;
        final py = y + math.sin(angle) * height * .5 * wobble;
        if (j == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      path.close();
      canvas.drawPath(path, Paint()..color = terrain[i % terrain.length]);
    }
    canvas.restore();

    final shadowCenter = center + Offset(radius * .43, radius * .10);
    canvas.drawCircle(
      shadowCenter,
      radius * .84,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: .62)],
        ).createShader(Rect.fromCircle(center: shadowCenter, radius: radius * .84)),
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 1.01),
      math.pi * .62,
      math.pi * .84,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.15
        ..color = Colors.white.withValues(alpha: .24),
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
          border: Border.all(color: Colors.white12),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(world.title, style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(world.description, style: const TextStyle(color: Colors.white54)),
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

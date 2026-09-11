import 'dart:math' as math;
import 'package:flutter/material.dart';

class DarkestGalaxy extends StatefulWidget {
  final List<GalaxyWorld> worlds;
  final ValueChanged<GalaxyWorld>? onWorldTap;

  const DarkestGalaxy({super.key, required this.worlds, this.onWorldTap});

  @override
  State<DarkestGalaxy> createState() => _DarkestGalaxyState();
}

class _DarkestGalaxyState extends State<DarkestGalaxy>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 70),
  )..repeat();

  int? selected;

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: _UniversePainter(_motion)),
              ),
            ),
            Center(
              child: _PlanetSystem(
                compact: compact,
                worlds: widget.worlds,
                selected: selected,
                onSelect: (index) => setState(() => selected = index),
              ),
            ),
            Positioned(
              left: compact ? 18 : 32,
              top: compact ? 18 : 28,
              child: const _Heading(),
            ),
            Positioned(
              right: compact ? 18 : 32,
              top: compact ? 18 : 28,
              child: _WorldCounter(count: widget.worlds.length),
            ),
            if (selected != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: _WorldPanel(
                    world: widget.worlds[selected!],
                    onClose: () => setState(() => selected = null),
                    onEnter: () => widget.onWorldTap?.call(widget.worlds[selected!]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PlanetSystem extends StatelessWidget {
  final bool compact;
  final List<GalaxyWorld> worlds;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _PlanetSystem({
    required this.compact,
    required this.worlds,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final width = math.min(screen.width * .94, compact ? 820.0 : 1380.0);
    final height = math.min(screen.height * .76, compact ? 620.0 : 760.0);
    final center = Offset(width * .5, height * .5);
    final orbitW = width * (compact ? .78 : .72);
    final orbitH = height * (compact ? .56 : .60);

    final positions = <Offset>[];
    final sizes = <double>[];
    final count = math.min(worlds.length, 9);

    for (var i = 0; i < count; i++) {
      if (i == 0) {
        positions.add(center);
        sizes.add(compact ? 126 : 188);
        continue;
      }
      final angle = -math.pi / 2 + ((i - 1) / math.max(1, count - 1)) * math.pi * 2;
      final ring = i.isEven ? 1.0 : .72;
      positions.add(Offset(
        center.dx + math.cos(angle) * orbitW * .5 * ring,
        center.dy + math.sin(angle) * orbitH * .5 * ring,
      ));
      sizes.add(compact ? (i < 5 ? 78 : 68) : (i < 5 ? 112 : 94));
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _OrbitPainter(center: center, width: orbitW, height: orbitH),
            ),
          ),
          for (var i = 0; i < count; i++)
            Positioned(
              left: positions[i].dx - sizes[i] / 2,
              top: positions[i].dy - sizes[i] / 2,
              child: _PlanetNode(
                world: worlds[i],
                size: sizes[i],
                central: i == 0,
                selected: selected == i,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanetNode extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final bool central;
  final bool selected;
  final VoidCallback onTap;

  const _PlanetNode({
    required this.world,
    required this.size,
    required this.central,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size + 120,
          height: size + 62,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              if (selected)
                Positioned(
                  top: -12,
                  child: Container(
                    width: size + 24,
                    height: size + 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFBBA1F1).withValues(alpha: .65),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7651B6).withValues(alpha: .28),
                          blurRadius: 30,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _PlanetPainter(
                    kind: world.kind,
                    seed: world.kind.index * 173 + 31,
                    central: central,
                  ),
                ),
              ),
              Positioned(
                top: size + 9,
                left: 0,
                right: 0,
                child: Text(
                  world.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: central ? 12 : 9,
                    letterSpacing: central ? 4 : 2.4,
                    fontWeight: central ? FontWeight.w500 : FontWeight.w400,
                    color: Colors.white.withValues(alpha: selected || central ? .9 : .55),
                    shadows: const [Shadow(color: Colors.black, blurRadius: 16)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DARKESTWORLD',
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 6,
              color: Colors.white.withValues(alpha: .86),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'THE WORLDS BEYOND',
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 3.4,
              color: Colors.white.withValues(alpha: .30),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldCounter extends StatelessWidget {
  final int count;
  const _WorldCounter({required this.count});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
        ),
        child: Text(
          '$count WORLDS',
          style: TextStyle(
            fontSize: 8,
            letterSpacing: 2.7,
            color: Colors.white.withValues(alpha: .40),
          ),
        ),
      ),
    );
  }
}

class _UniversePainter extends CustomPainter {
  final Animation<double> animation;
  _UniversePainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.08),
          radius: 1.15,
          colors: [Color(0xFF171025), Color(0xFF06050C), Color(0xFF010106)],
        ).createShader(rect),
    );

    final random = math.Random(731);
    final stars = Paint();
    for (var i = 0; i < 520; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final pulse = .65 + .35 * math.sin(animation.value * math.pi * 2 + i);
      stars.color = Colors.white.withValues(alpha: (.025 + random.nextDouble() * .18) * pulse);
      canvas.drawCircle(p, .25 + random.nextDouble() * .8, stars);
    }

    final nebula = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF684A91).withValues(alpha: .075),
          const Color(0xFF385D86).withValues(alpha: .025),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .48),
        width: size.width * .9,
        height: size.height * .72,
      ));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .48),
        width: size.width * .9,
        height: size.height * .72,
      ),
      nebula,
    );
  }

  @override
  bool shouldRepaint(covariant _UniversePainter oldDelegate) => false;
}

class _OrbitPainter extends CustomPainter {
  final Offset center;
  final double width;
  final double height;

  const _OrbitPainter({required this.center, required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final orbit = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = const Color(0xFF8C72B6).withValues(alpha: .075);

    for (final factor in [.56, .78, 1.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: width * factor,
          height: height * factor,
        ),
        orbit,
      );
    }

    final cross = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .45
      ..color = const Color(0xFF6680A2).withValues(alpha: .045);
    canvas.drawLine(
      Offset(center.dx - width * .55, center.dy),
      Offset(center.dx + width * .55, center.dy),
      cross,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - height * .55),
      Offset(center.dx, center.dy + height * .55),
      cross,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}

class _PlanetPainter extends CustomPainter {
  final GalaxyWorldKind kind;
  final int seed;
  final bool central;

  const _PlanetPainter({required this.kind, required this.seed, required this.central});

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    final rect = Offset.zero & size;
    final colors = _palette(kind);

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.38),
          radius: 1.05,
          colors: [colors.$1, colors.$2, const Color(0xFF020208)],
          stops: const [0, .58, 1],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * .985)));

    final random = math.Random(seed);
    final terrain = Paint()..style = PaintingStyle.fill;
    final land = _land(kind);

    for (var i = 0; i < (central ? 10 : 4); i++) {
      final cx = c.dx + (random.nextDouble() * 2 - 1) * r * .58;
      final cy = c.dy + (random.nextDouble() * 2 - 1) * r * .52;
      final rw = r * (.18 + random.nextDouble() * .25);
      final rh = r * (.10 + random.nextDouble() * .18);
      final path = Path();
      for (var p = 0; p < 12; p++) {
        final a = p / 12 * math.pi * 2;
        final wobble = .72 + random.nextDouble() * .48;
        final point = Offset(
          cx + math.cos(a) * rw * wobble,
          cy + math.sin(a) * rh * wobble,
        );
        if (p == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      terrain.color = land.withValues(alpha: .34 + random.nextDouble() * .20);
      canvas.drawPath(path, terrain);
    }

    final texture = Paint();
    for (var i = 0; i < (central ? 100 : 32); i++) {
      final x = c.dx + (random.nextDouble() * 2 - 1) * r * .84;
      final y = c.dy + (random.nextDouble() * 2 - 1) * r * .84;
      if ((Offset(x, y) - c).distance < r * .91) {
        texture.color = Colors.white.withValues(alpha: .012 + random.nextDouble() * .035);
        canvas.drawCircle(Offset(x, y), .4 + random.nextDouble() * 1.4, texture);
      }
    }

    final atmosphere = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .025
      ..color = const Color(0xFFB9A8D8).withValues(alpha: central ? .13 : .09);
    canvas.drawCircle(c, r * .94, atmosphere);

    canvas.restore();

    canvas.drawCircle(
      c + Offset(-r * .22, -r * .28),
      r * .70,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: central ? .07 : .045), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c + Offset(-r * .22, -r * .28), radius: r * .70)),
    );

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: central ? .20 : .12),
    );
  }

  (Color, Color) _palette(GalaxyWorldKind kind) => switch (kind) {
        GalaxyWorldKind.vegeta => (const Color(0xFF694C98), const Color(0xFF171128)),
        GalaxyWorldKind.game => (const Color(0xFF42608F), const Color(0xFF10182D)),
        GalaxyWorldKind.music => (const Color(0xFF3E718B), const Color(0xFF0D1C2A)),
        GalaxyWorldKind.identity => (const Color(0xFF704B87), const Color(0xFF1A1025)),
        GalaxyWorldKind.family => (const Color(0xFF4B707D), const Color(0xFF101A20)),
        GalaxyWorldKind.cinema => (const Color(0xFF754F72), const Color(0xFF1B1220)),
        GalaxyWorldKind.creation => (const Color(0xFF466E91), const Color(0xFF101A28)),
        GalaxyWorldKind.archive => (const Color(0xFF5D6478), const Color(0xFF151722)),
        GalaxyWorldKind.comingSoon => (const Color(0xFF73519A), const Color(0xFF191027)),
      };

  Color _land(GalaxyWorldKind kind) => switch (kind) {
        GalaxyWorldKind.vegeta => const Color(0xFF9A7869),
        GalaxyWorldKind.game => const Color(0xFF718A70),
        GalaxyWorldKind.music => const Color(0xFF5D7F70),
        GalaxyWorldKind.identity => const Color(0xFF80658B),
        GalaxyWorldKind.family => const Color(0xFF69817A),
        GalaxyWorldKind.cinema => const Color(0xFF80636C),
        GalaxyWorldKind.creation => const Color(0xFF637D8D),
        GalaxyWorldKind.archive => const Color(0xFF747783),
        GalaxyWorldKind.comingSoon => const Color(0xFF806493),
      };

  @override
  bool shouldRepaint(covariant _PlanetPainter oldDelegate) => false;
}

class _WorldPanel extends StatelessWidget {
  final GalaxyWorld world;
  final VoidCallback onClose;
  final VoidCallback onEnter;

  const _WorldPanel({required this.world, required this.onClose, required this.onEnter});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF090711).withValues(alpha: .94),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: .10)),
            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 35)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      world.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, letterSpacing: 2.8),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      world.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: .46),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: onEnter,
                child: const Text('ENTER', style: TextStyle(letterSpacing: 2.2, fontSize: 10)),
              ),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 17)),
            ],
          ),
        ),
      ),
    );
  }
}

enum GalaxyWorldKind {
  vegeta,
  game,
  music,
  identity,
  family,
  cinema,
  creation,
  archive,
  comingSoon,
}

class GalaxyWorld {
  final String title;
  final String description;
  final GalaxyWorldKind kind;

  const GalaxyWorld(this.title, this.description, this.kind);
}

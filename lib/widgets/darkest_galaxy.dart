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
    duration: const Duration(seconds: 90),
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
            RepaintBoundary(
              child: CustomPaint(painter: _GalaxyPainter(_motion)),
            ),
            Center(
              child: InteractiveViewer(
                minScale: .65,
                maxScale: 1.45,
                panEnabled: true,
                scaleEnabled: true,
                boundaryMargin: const EdgeInsets.all(80),
                child: _WorldMap(
                  compact: compact,
                  worlds: widget.worlds,
                  selected: selected,
                  onSelect: (i) => setState(() => selected = i),
                ),
              ),
            ),
            Positioned(
              left: compact ? 18 : 30,
              top: compact ? 18 : 26,
              child: const _GalaxyHeading(),
            ),
            Positioned(
              right: compact ? 18 : 30,
              top: compact ? 18 : 26,
              child: _WorldCounter(count: widget.worlds.length),
            ),
            if (selected != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  minimum: const EdgeInsets.only(bottom: 18),
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

class _WorldMap extends StatelessWidget {
  final bool compact;
  final List<GalaxyWorld> worlds;
  final int? selected;
  final ValueChanged<int> onSelect;

  const _WorldMap({
    required this.compact,
    required this.worlds,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final width = math.min(screen.width * .88, compact ? 760.0 : 1280.0);
    final height = math.min(screen.height * .70, compact ? 610.0 : 700.0);
    final center = Offset(width * .50, height * .50);

    final positions = compact
        ? <Offset>[
            center,
            Offset(width * .10, height * .16),
            Offset(width * .78, height * .12),
            Offset(width * .82, height * .62),
            Offset(width * .13, height * .68),
            Offset(width * .35, height * .86),
            Offset(width * .58, height * .08),
            Offset(width * .63, height * .86),
            Offset(width * .32, height * .08),
          ]
        : <Offset>[
            center,
            Offset(width * .08, height * .25),
            Offset(width * .78, height * .17),
            Offset(width * .89, height * .57),
            Offset(width * .08, height * .64),
            Offset(width * .30, height * .86),
            Offset(width * .62, height * .89),
            Offset(width * .61, height * .10),
            Offset(width * .31, height * .09),
          ];

    final sizes = compact
        ? <double>[190, 78, 82, 86, 80, 72, 72, 76, 70]
        : <double>[280, 105, 112, 118, 108, 92, 98, 94, 88];

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _WorldLinesPainter())),
          for (var i = 0; i < worlds.length && i < positions.length; i++)
            Positioned(
              left: positions[i].dx - sizes[i] / 2,
              top: positions[i].dy - sizes[i] / 2,
              child: _WorldNode(
                world: worlds[i],
                size: sizes[i],
                index: i,
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

class _WorldNode extends StatelessWidget {
  final GalaxyWorld world;
  final double size;
  final int index;
  final bool central;
  final bool selected;
  final VoidCallback onTap;

  const _WorldNode({
    required this.world,
    required this.size,
    required this.index,
    required this.central,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelBelow = size < 100;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: math.max(size + 130, 220),
        height: size + (labelBelow ? 54 : 38),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            if (selected)
              Positioned(
                top: -10,
                child: Container(
                  width: size + 22,
                  height: size + 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFB99BFF).withValues(alpha: .72),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8154D8).withValues(alpha: .35),
                        blurRadius: 34,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 0,
              child: SizedBox(
                width: size,
                height: size,
                child: CustomPaint(
                  painter: _WorldSpherePainter(
                    seed: index * 91 + 17,
                    kind: world.kind,
                    central: central,
                  ),
                ),
              ),
            ),
            Positioned(
              top: size + 8,
              left: 0,
              right: 0,
              child: Text(
                world.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: central ? 12 : 9,
                  letterSpacing: central ? 3.0 : 2.0,
                  fontWeight: central ? FontWeight.w500 : FontWeight.w400,
                  color: Colors.white.withValues(alpha: selected || central ? .92 : .58),
                  shadows: const [Shadow(color: Colors.black, blurRadius: 14)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalaxyHeading extends StatelessWidget {
  const _GalaxyHeading();

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
          const SizedBox(height: 5),
          Text(
            'A LIVING WORLD',
            style: TextStyle(
              fontSize: 8,
              letterSpacing: 3.5,
              color: Colors.white.withValues(alpha: .32),
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
          color: Colors.black.withValues(alpha: .20),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: .09)),
        ),
        child: Text(
          '$count WORLDS',
          style: TextStyle(
            fontSize: 8,
            letterSpacing: 2.7,
            color: Colors.white.withValues(alpha: .42),
          ),
        ),
      ),
    );
  }
}

class _GalaxyPainter extends CustomPainter {
  final Animation<double> animation;
  _GalaxyPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.05),
          radius: 1.15,
          colors: [Color(0xFF171027), Color(0xFF05040B), Color(0xFF010106)],
        ).createShader(rect),
    );

    final random = math.Random(731);
    final stars = Paint();
    for (var i = 0; i < 620; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final pulse = .55 + .45 * math.sin(animation.value * math.pi * 2 + i * 1.17);
      stars.color = Colors.white.withValues(
        alpha: (.018 + random.nextDouble() * .24) * pulse,
      );
      canvas.drawCircle(Offset(x, y), .3 + random.nextDouble() * .9, stars);
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6B4AA5).withValues(alpha: .10),
          const Color(0xFF315F9B).withValues(alpha: .035),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCenter(
          center: Offset(size.width * .5, size.height * .5),
          width: size.width * .75,
          height: size.height * .55,
        ),
      );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .5),
        width: size.width * .75,
        height: size.height * .55,
      ),
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) => false;
}

class _WorldLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .5);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF8663BD).withValues(alpha: .075);

    for (final scale in [.32, .52, .72, .92]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: size.width * scale,
          height: size.height * scale * .38,
        ),
        line,
      );
    }

    final route = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .7
      ..color = const Color(0xFF7893BD).withValues(alpha: .035);
    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * .98,
        height: size.height * .25,
      ),
      route,
    );
  }

  @override
  bool shouldRepaint(covariant _WorldLinesPainter oldDelegate) => false;
}

class _WorldSpherePainter extends CustomPainter {
  final int seed;
  final GalaxyWorldKind kind;
  final bool central;

  _WorldSpherePainter({
    required this.seed,
    required this.kind,
    required this.central,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = size.center(Offset.zero);
    final rect = Offset.zero & size;

    final ocean = _oceanColors(kind);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.38, -.42),
          radius: 1.05,
          colors: [ocean.$1, ocean.$2, const Color(0xFF02030A)],
          stops: const [0, .58, 1],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * .985)));

    final random = math.Random(seed);
    final land = Paint()..style = PaintingStyle.fill;
    final landColor = _landColor(kind);

    // Large, irregular landmasses: this makes the worlds read as actual places,
    // rather than flat UI circles.
    for (var i = 0; i < (central ? 9 : 5); i++) {
      final cx = c.dx + (random.nextDouble() * 2 - 1) * r * .62;
      final cy = c.dy + (random.nextDouble() * 2 - 1) * r * .55;
      final rw = r * (.22 + random.nextDouble() * .25);
      final rh = r * (.12 + random.nextDouble() * .20);
      final path = Path();
      for (var p = 0; p < 11; p++) {
        final a = p / 11 * math.pi * 2;
        final wobble = .72 + random.nextDouble() * .42;
        final x = cx + math.cos(a) * rw * wobble;
        final y = cy + math.sin(a) * rh * wobble;
        if (p == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      land.color = landColor.withValues(alpha: .42 + random.nextDouble() * .18);
      canvas.drawPath(path, land);
    }

    // Subtle terrain flecks and coast highlights.
    final detail = Paint();
    for (var i = 0; i < (central ? 150 : 50); i++) {
      final x = c.dx + (random.nextDouble() * 2 - 1) * r * .82;
      final y = c.dy + (random.nextDouble() * 2 - 1) * r * .82;
      if ((Offset(x, y) - c).distance < r * .9) {
        detail.color = Colors.white.withValues(alpha: .018 + random.nextDouble() * .045);
        canvas.drawCircle(Offset(x, y), .5 + random.nextDouble() * 1.6, detail);
      }
    }

    // Curved cloud bands.
    final cloud = Paint()
      ..color = Colors.white.withValues(alpha: central ? .055 : .035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .035;
    for (var i = 0; i < 4; i++) {
      final y = c.dy - r * .48 + i * r * .28;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(c.dx, y),
          width: r * 1.75,
          height: r * .28,
        ),
        math.pi * .08,
        math.pi * .84,
        false,
        cloud,
      );
    }

    canvas.restore();

    // Atmospheric rim and light falloff.
    canvas.drawCircle(
      c,
      r * .985,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * .022
        ..color = const Color(0xFFB79DEB).withValues(alpha: central ? .16 : .10),
    );

    canvas.drawCircle(
      c + Offset(-r * .22, -r * .27),
      r * .72,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white.withValues(alpha: .055), Colors.transparent],
        ).createShader(Rect.fromCircle(center: c, radius: r * .72)),
    );
  }

  (Color, Color) _oceanColors(GalaxyWorldKind kind) => switch (kind) {
        GalaxyWorldKind.vegeta => (const Color(0xFF62469A), const Color(0xFF171128)),
        GalaxyWorldKind.game => (const Color(0xFF425E91), const Color(0xFF10182D)),
        GalaxyWorldKind.music => (const Color(0xFF3B6D8B), const Color(0xFF0D1C2A)),
        GalaxyWorldKind.identity => (const Color(0xFF714B86), const Color(0xFF1B1025)),
        GalaxyWorldKind.family => (const Color(0xFF496D7D), const Color(0xFF101A20)),
        GalaxyWorldKind.cinema => (const Color(0xFF745273), const Color(0xFF1B1220)),
        GalaxyWorldKind.creation => (const Color(0xFF426D91), const Color(0xFF101A28)),
        GalaxyWorldKind.archive => (const Color(0xFF5B6175), const Color(0xFF151722)),
        GalaxyWorldKind.comingSoon => (const Color(0xFF76549C), const Color(0xFF191027)),
      };

  Color _landColor(GalaxyWorldKind kind) => switch (kind) {
        GalaxyWorldKind.vegeta => const Color(0xFF9B7A69),
        GalaxyWorldKind.game => const Color(0xFF718A70),
        GalaxyWorldKind.music => const Color(0xFF78907C),
        GalaxyWorldKind.identity => const Color(0xFF9A7890),
        GalaxyWorldKind.family => const Color(0xFF748D79),
        GalaxyWorldKind.cinema => const Color(0xFF9A7C70),
        GalaxyWorldKind.creation => const Color(0xFF788D72),
        GalaxyWorldKind.archive => const Color(0xFF85847A),
        GalaxyWorldKind.comingSoon => const Color(0xFF8D7694),
      };

  @override
  bool shouldRepaint(covariant _WorldSpherePainter oldDelegate) => false;
}

class _WorldPanel extends StatelessWidget {
  final GalaxyWorld world;
  final VoidCallback onClose;
  final VoidCallback onEnter;

  const _WorldPanel({
    required this.world,
    required this.onClose,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width - 28, 560.0);
    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.fromLTRB(20, 16, 10, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF08060E).withValues(alpha: .94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF9B76D2).withValues(alpha: .23)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5F3E91).withValues(alpha: .18),
            blurRadius: 38,
          ),
        ],
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
                  style: const TextStyle(fontSize: 13, letterSpacing: 2.6),
                ),
                const SizedBox(height: 5),
                Text(
                  world.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: .48),
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close, size: 17)),
          TextButton(onPressed: onEnter, child: const Text('ENTER')),
        ],
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
